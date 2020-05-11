provider "google" {
  credentials = "${file("inlaid-fire-254211-b3928da874b8.json")}"
  project = "inlaid-fire-254211"
  region  = "us-central1"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_subnetwork" "public-subnetwork" {
  name          = "terraform-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
}

resource "google_compute_instance" "default" {
 name         = "flask-vm"
 machine_type = "f1-micro"
 zone         = "us-central1-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

 network_interface {
   network = "terraform-network"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

