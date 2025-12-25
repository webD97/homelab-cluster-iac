terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.90.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "2.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.37.1:8006/"
  # We're using a self-signed TLS certificate
  insecure = true

  ssh {
    agent = true
  }
}
