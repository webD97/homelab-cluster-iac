terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.96.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}
