variable "cluster_name" {
  type    = string
}

variable "controlplane_count" {
  type    = number
  default = 1
}

variable "worker_count" {
  type    = number
  default = 1
}

variable "vm_keymap" {
  type    = string
  default = "us"
}

variable "vm_ssh_authorized_key" {
  type = string
}

variable "sealed_secrets_initial_cert" {
  type = object({
    cert = string
    key  = string
  })
}

variable "fleet_kickstart_repo" {
  type = object({
    repo_url = string
    branch   = string
    path     = string
  })
}
