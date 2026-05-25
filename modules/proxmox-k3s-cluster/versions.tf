terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.107.0"
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
      version = "2.9.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}
