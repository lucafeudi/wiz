# Create overprivileged service account for the database VM
resource "google_service_account" "overprivileged_sa" {
  account_id   = "db-vm-editor-sa"
  display_name = "DB VM Overprivileged Service Account"
}

resource "google_project_iam_member" "sa_editor_binding" {
  project = var.project_id
  role    = "roles/editor" # Intentionally overprivileged (Wiz High/Critical finding)
  member  = "serviceAccount:${google_service_account.overprivileged_sa.email}"
}

resource "google_compute_instance" "legacy_db" {
  name         = "legacy-mongodb-host"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  # Ubuntu 20.04 LTS is over 4 years old (Outdated OS finding)
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.db_subnet_id
    access_config {
      # Assuring an external IP address is attached to allow public SSH discovery
    }
  }

  metadata = {
    # Startup script to install MongoDB 4.4 (Outdated, CVE-prone version released in 2020)
    startup-script = <<-EOT
      #!/bin/bash
      apt-get update -y
      apt-get install -y gnupg wget
      wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
      echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
      apt-get update -y
      apt-get install -y mongodb-org=4.4.18 mongodb-org-server=4.4.18 mongodb-org-shell=4.4.18 mongodb-org-mongos=4.4.18 mongodb-org-tools=4.4.18
      
      # Expose MongoDB on all interfaces
      sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
      
      # Enable Authentication
      echo -e "security:\n  authorization: enabled" >> /etc/mongod.conf
      
      systemctl daemon-reload
      systemctl restart mongod
      systemctl enable mongod

      # Create Admin User in MongoDB
      sleep 10
      mongo admin --eval 'db.createUser({user: "wizadmin", pwd: "SuperSecretWizPassword2026!", roles: [{role: "root", db: "admin"}]})'
    EOT
  }

  tags = ["public-ssh-vm", "mongodb-tier"]

  service_account {
    email  = google_service_account.overprivileged_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
