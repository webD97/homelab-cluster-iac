terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.60.0"
    }
    truenas = {
      source  = "dariusbakunas/truenas"
      version = "0.11.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
