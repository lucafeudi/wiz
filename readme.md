wiz-gcp-infrastructure/
├── terraform/
│   ├── providers.tf         # GCP & Kubernetes providers
│   ├── variables.tf         # Input variables (project_id, region, etc.)
│   ├── iam_wif.tf           # Workload Identity Federation for GitHub Actions
│   ├── vpc.tf               # VPC, public subnet, private subnet & firewall rules
│   ├── storage.tf           # Publicly readable/listable GCS bucket for backups
│   ├── compute.tf           # Outdated OS (Ubuntu 20.04) + MongoDB 4.4 + Backup cron
│   └── gke.tf               # Private GKE Cluster & Node Pools
├── app/
│   ├── Dockerfile           # Builds image, creates wizexercise.txt ("Luca Feudi")
│   ├── requirements.txt     # Python dependencies (Flask, PyMongo)
│   └── app.py               # Web app connecting to MongoDB with health/verify endpoints
├── k8s/
│   └── deployment.yaml      # App deployment, Service, Cluster-Admin RBAC, and Ingress
└── .github/
    └── workflows/
        ├── iac-deploy.yml   # GitHub Actions pipeline for Terraform via WIF
        └── app-ci-cd.yml    # GitHub Actions pipeline for Container Build & GKE Deploy