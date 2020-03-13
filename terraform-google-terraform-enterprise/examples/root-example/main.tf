variable "region" {
  default = "us-central1"
}

variable "project" {}

provider "google" {
  region  = "${var.region}"
  project = "${var.project}"
}

provider "google-beta" {
  region  = "${var.region}"
  project = "${var.project}"
}

/* resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta

  name = "test-cert"

  managed {
    domains = ["richard.tfe.com"]
  }
} */

module "tfe-cluster" {
  source           = "hashicorp/terraform-enterprise/google"
  version          = "0.1.1"
  credentials_file = "/Users/richp/Documents/Dropbox/Work/DigitalOnUs/proj/gcp_tfe/richgcptfe-de56ad7c234b.json"
  region           = "${var.region}"
  zone             = "${var.region}-a"
  project          = "${var.project}"
  domain           = "richard.tfe.com"
  dns_zone         = "richard-terraform-ent-zone"
  public_ip        = "35.190.12.231"
  # uploaded to GCP cert
  certificate      = "test-cert-2"
  # self-managed cert
  #certificate      = "/Users/richp/Documents/Dropbox/Work/DigitalOnUs/proj/gcp_tfe/certs/vault_cert.pem"
  ssl_policy       = "ptfe-ssl-policy"
  subnet           = "ptfe-subnet"
  frontend_dns     = "tfe.richard.tfe.com"

  primary_count   = "3"
#  min_secondaries = "2"
#  max_secondaries = "5"

  license_file = "/Users/richp/Documents/Dropbox/Work/DigitalOnUs/proj/gcp_tfe/digitalonus.rli"
}

output "tfe-cluster" {
  value = {
    application_endpoint         = "${module.tfe-cluster.application_endpoint}"
    application_health_check     = "${module.tfe-cluster.application_health_check}"
    installer_dashboard_password = "${module.tfe-cluster.installer_dashboard_password}"
    installer_dashboard__url     = "${module.tfe-cluster.installer_dashboard_url}"
    primary_public_ip            = "${module.tfe-cluster.primary_public_ip}"
    encryption_password          = "${module.tfe-cluster.encryption_password}"
  }
}
