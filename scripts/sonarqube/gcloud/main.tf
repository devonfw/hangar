provider "google" {
  credentials = "${file(var.service_account_file)}"
  project     = var.project
  region      = var.region
  zone        = var.zone
}

#create VPC
resource "google_compute_network" "sonarqube_vpc_network" {
  name                    = "sonarqube-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

#create subnet
resource "google_compute_subnetwork" "sonarqube_subnet" {
  name          = "sonarqube-subnet"
  ip_cidr_range = var.subnet_cidr_block
  region        = var.region
  network       = google_compute_network.sonarqube_vpc_network.id
}

#create static ip
resource "google_compute_address" "sonarqube-static-ip-address" {
  name = "sonarqube-static-ip-address"
}

# Create a single Compute Engine instance
resource "google_compute_instance" "sonarqube_vm" {
  name         = "sonarqube-vm"
  machine_type = var.instance_type
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Cloud config script for setting up SonarQube
  metadata_startup_script = "${file("../common/setup_sonarqube.sh")}"

  network_interface {
    subnetwork = google_compute_subnetwork.sonarqube_subnet.id

    access_config {
      # Include this section to give the VM an external IP address
      nat_ip = "${google_compute_address.sonarqube-static-ip-address.address}"
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
  network       = google_compute_network.sonarqube_vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Allow Sonarqube port
resource "google_compute_firewall" "sonarqube_firewall" {
  name    = "default-sonarqube-firewall"
  network = google_compute_network.sonarqube_vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }
  priority      = 1002
  source_ranges = ["0.0.0.0/0"]
}

# Generate sonarqube token
data "external" "sonarqube_create_token" {
  program = ["sh", "-c", "${path.module}/../common/create_token.sh -p ${var.sonarqube_password} -s http://${google_compute_address.sonarqube-static-ip-address.address}:9000 tf-output-sq-token sonarqube_token"]
  
  # Ensure firewall rule for sonar qube is provisioned before server, so that create sonarqube token doesn't fail.
  depends_on = [ 
    google_compute_instance.sonarqube_vm,
    google_compute_firewall.sonarqube_firewall,
    google_compute_address.sonarqube-static-ip-address
  ]
}

#outputs
output "sonarqube_url" {
  value = "http://${google_compute_address.sonarqube-static-ip-address.address}:9000"
}

output "sonarqube_token" {
  value = "${data.external.sonarqube_create_token.result.token}"
}
