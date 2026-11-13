# Overly Permissive Service Account for MongoDB VM (e.g. roles/editor)
resource "google_service_account" "mongo_sa" {
  account_id   = "mongo-vm-sa"
  display_name = "Overly Permissive Mongo VM Service Account"
}

resource "google_project_iam_member" "mongo_sa_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.mongo_sa.email}"
}

resource "google_project_iam_member" "mongo_sa_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.mongo_sa.email}"
}

resource "google_project_iam_member" "mongo_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.mongo_sa.email}"
}

resource "google_compute_address" "mongo_static_ip" {
  name         = "wiz-mongodb-static-ip"
  project      = var.project_id
  region       = "europe-west1"
  address_type = "EXTERNAL"  
}

# Virtual Machine with Outdated Linux (Ubuntu 20.04 LTS released in 2020) & Outdated MongoDB (4.4)
resource "google_compute_instance" "mongo_vm" {
  name         = "wiz-mongodb-vm"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["mongodb-vm"]

  boot_disk {
    initialize_params {
      # Updated image reference for Ubuntu 20.04 LTS
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
      size  = 30
    }
  }

  network_interface {
      subnetwork = "wiz-public-subnet"
      access_config {
        nat_ip = google_compute_address.mongo_static_ip.address
      }
    }

  service_account {
    email  = google_service_account.mongo_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y gnupg wget

    # Install Outdated MongoDB 4.4
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
    apt-get update
    apt-get install -y mongodb-org=4.4.18 mongodb-org-server=4.4.18 mongodb-org-shell=4.4.18 mongodb-org-mongos=4.4.18 mongodb-org-tools=4.4.18 mongosh

    # Configure MongoDB to listen on all interfaces (or internal IP) with auth
    sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

    systemctl daemon-reload
    systemctl start mongod
    systemctl enable mongod

    # Set up root admin user and database credentials
    sleep 10
    mongosh --eval 'db.getSiblingDB("admin").createUser({user: "admin", pwd: "SecurePassword123!", roles: [{role: "root", db: "admin"}]})'

    # Setup automated daily backup to public GCS bucket
    cat << 'EOF' > /usr/local/bin/mongo-backup.sh
    #!/bin/bash
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="/tmp/mongo_backup_$TIMESTAMP"
    mongodump --uri="mongodb://admin:SecurePassword123!@localhost:27017/admin?authSource=admin" --out=$BACKUP_DIR
    tar -zcvf /tmp/mongo_backup_$TIMESTAMP.tar.gz -C $BACKUP_DIR .
    /snap/bin/gsutil cp /tmp/mongo_backup_$TIMESTAMP.tar.gz gs://${google_storage_bucket.backups.name}/backup_$TIMESTAMP.tar.gz
    rm -rf $BACKUP_DIR /tmp/mongo_backup_$TIMESTAMP.tar.gz
    EOF

    chmod +x /usr/local/bin/mongo-backup.sh
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/mongo-backup.sh") | crontab -
  EOT
  # Prevent Terraform from recreating the VM when the image family updates
  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
    ]
  }
}
