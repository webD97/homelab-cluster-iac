module "proxmox-homelab-cluster-prod" {
  source = "./modules/proxmox-k3s-cluster"

  cluster_name = "homelab"

  vm_ssh_authorized_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDytfbbDrd6G6EfOjq93qZ2+ND95/1/y9ly75EFcR3fj1gtqLG3LiFssyFkf79tamlE8+KgUWE8Kb4a8QqKEyX0vwdYytTHsa4q8ifaq2vy6APnYvGeXy6mVUWzpgT+yOK1UU9iq3s4dlS5WgQUHJ+10dbs8TWw/jgsqjKCJhUI/rT3lZg9yBZ+BSsux2aKZjs7g7+94qk1ZDVADtBs5jF34N6I2CCLy8DfjBsJ0arMdOrZS5TCyxM+FUDGqN/DMkA14907NRgqjxk5QOlLAsi/qN3g6ZRDx+nCMBUTC+ALxizaQeAZhELyMisi+TJbDGQoN7IJC8i/mz8KKmt/3cnJ christian@Fedora-WS"
  vm_keymap             = "de"

  worker_count = 2

  sealed_secrets_initial_cert = {
    key  = file("./sealed-secrets/sealed-secrets.key")
    cert = file("./sealed-secrets/sealed-secrets.crt")
  }

  fleet_kickstart_repo = {
    repo_url = "https://github.com/webD97/homelab-cluster-gitops"
    branch   = "main"
    path     = "_bundles"
  }
}
