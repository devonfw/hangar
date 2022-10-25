#create VPC
resource "google_compute_network" "vpc_network" {
  name                    = "sq_vpc"
  auto_create_subnetworks = false
  mtu                     = 1460

  target_tags = ["sonarqube_vpc"]
}

#create subnet
resource "google_compute_subnetwork" "default" {
  name          = "sq_subnet"
  ip_cidr_range = var.subnet_cidr_range
  region        = var.gcloud_region
  network       = google_compute_network.vpc_network.id

  target_tags = ["sonarqube_subnet"]
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "flask-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Cloud config script for setting up SonarQube
  metadata_startup_script = file("../common/setup_sonarqube.sh")

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

# Allow SSH
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh_sonarqube"]
}

# Allow http and https
resource "google_compute_firewall" "http_https" {
  name    = "allow_http_https"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }
  priority      = 1001
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http_https_sonarqube"]
}

# Allow Sonarqube port
resource "google_compute_firewall" "default" {
  name    = "default-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }
  priority      = 1002
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["firewall_sonarqube"]
}
