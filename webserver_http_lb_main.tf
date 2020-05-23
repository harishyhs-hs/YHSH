resource "google_compute_instance_template" "webserver" {
  name         = "standard-webserver"
  machine_type = "n1-standard-1"
  metadata_startup_script = "apt-get update && apt-get install -y nginx"

  network_interface {
    network = "default"
    access_config {
  }
}

disk {   
  source_image = "debian-cloud/debian-9"
  auto_delete = true
  boot        = true
 }
}

resource "google_compute_instance_group_manager" "webservers" {
  name               = "my-webservers"
  base_instance_name = "webserver"
  zone               = "us-west1-a"
  version {
  instance_template  = "${google_compute_instance_template.webserver.self_link}"
}
  target_size        = 4
  named_port {
    name = "http"
    port = 80
  }
}
resource "google_compute_backend_service" "website" {
  name               = "my-backend"
  description        = "company_website"
  port_name          = "http"
  protocol           = "HTTP"
  timeout_sec        =  10
  enable_cdn         =  false 
  health_checks      =  [google_compute_http_health_check.default.id]
}

resource "google_compute_http_health_check" "default" {
  name         = "authentication-health-check"
  request_path = "/"

  timeout_sec        = 5
  check_interval_sec = 5
 }

module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 3.1"
  name              = "webserver"
  project           = "inlaid-fire-254211"
  target_tags       = ["http"]
 
backends = {
    default = {

      description                     = "company_website"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false


      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
      }

      groups = [
        {
          group                        = google_compute_instance_group_manager.webservers.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]
    }
  }

}
