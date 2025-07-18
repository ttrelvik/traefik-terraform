# Configure the required Terraform providers, in this case, the Docker provider.
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Define the Traefik container resource.
resource "docker_container" "traefik" {
  image = "traefik:v3.0"
  name  = "traefik"

  # Map ports from the host to the container.
  ports {
    internal = 443
    external = 443
  }

  # Mount volumes from the host into the container.
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    host_path      = "${path.cwd}/dynamic_conf.yml"
    container_path = "/etc/traefik/dynamic_conf.yml"
  }
  volumes {
    host_path      = "${path.cwd}/certs"
    container_path = "/etc/ssl"
  }

  # Define the startup command arguments for Traefik.
  command = [
    "--providers.docker=true",
    "--entrypoints.websecure.address=:443",
    "--providers.file.filename=/etc/traefik/dynamic_conf.yml",
    "--api.dashboard=true"
  ]

  # Add Docker labels that Traefik uses to configure itself.
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.dashboard.rule"
    value = "Host(`traefik.midna.local`)"
  }
  labels {
    label = "traefik.http.routers.dashboard.entrypoints"
    value = "websecure"
  }
  labels {
    label = "traefik.http.routers.dashboard.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.dashboard.service"
    value = "api@internal"
  }
}
