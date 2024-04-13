data "ct_config" "homelab_cluster_controlplane_ignition" {
  count  = var.controlplane_count
  strict = true
  content = templatefile("butane-templates/controlplane.yaml.tftpl", {
    ssh_authorized_key      = var.vm_ssh_authorized_key
    ssh_admin_username      = "admin"
    hostname                = "${var.cluster_name}-control-${count.index}"
    keymap                  = var.vm_keymap
    os_extensions_rpm_names = []
    etcd_nfs_host           = "truenas.fritz.box"
    etcd_nfs_path           = "/mnt/hdd-pool/homelab-k3s-etcd/${var.cluster_name}-control-${count.index}-etcd"
    init_cluster            = count.index == 0
    agent_token             = "${random_password.agent_token.result}"
    sealed_secrets_cert     = var.sealed_secrets_initial_cert.cert
    sealed_secrets_key      = var.sealed_secrets_initial_cert.key
    kubelet_config          = <<-EOF
      apiVersion: kubelet.config.k8s.io/v1beta1
      kind: KubeletConfiguration
      shutdownGracePeriod: 60s
      shutdownGracePeriodCriticalPods: 10s
    EOF
    k3s_download_url        = "https://github.com/k3s-io/k3s/releases/download/v1.29.3%2Bk3s1/k3s"
    k3s_download_hash       = "sha256-21b7542eeac71ffea09ee1efb9190bce7b77b8233ae13e12f3165c746c8559ee"
    zincati_update_strategy = <<-EOF
      [updates]
      strategy = "periodic"

      [updates.periodic]
      time_zone = "localtime"

      [[updates.periodic.window]]
      days = [ "Sun" ]
      start_time = "02:00"
      length_minutes = 60
    EOF
    initial_fleet_repo_yaml = <<-EOF
      apiVersion: fleet.cattle.io/v1alpha1
      kind: GitRepo
      metadata:
        name: cluster-kickstart
        namespace: fleet-local
      spec:
        repo: ${var.fleet_kickstart_repo.repo_url}
        branch: ${var.fleet_kickstart_repo.branch}
        pollingInterval: 3600s
        paths:
          - ${var.fleet_kickstart_repo.path}
    EOF
  })
}

resource "truenas_dataset" "controlplane_etcd_storage" {
  count       = var.controlplane_count
  pool        = "hdd-pool"
  parent      = "homelab-k3s-etcd"
  name        = "${var.cluster_name}-control-${count.index}-etcd"
  quota_bytes = 5 * 1024 * 1024 * 1024

  lifecycle {
    ignore_changes = [ comments ]
  }
}

resource "truenas_share_nfs" "controlplane_etcd_storage" {
  count = var.controlplane_count
  paths = [
    truenas_dataset.controlplane_etcd_storage[count.index].mount_point
  ]
  alldirs       = false
  enabled       = true
  maproot_user  = "root"
  maproot_group = "wheel"
}

resource "proxmox_virtual_environment_vm" "homelab_cluster_controlplane" {
  count = var.controlplane_count

  depends_on = [truenas_share_nfs.controlplane_etcd_storage]

  name        = "${var.cluster_name}-control-${count.index}"
  description = "Managed by OpenTofu"
  tags        = [var.cluster_name]

  node_name = "pve"
  machine   = "q35"

  agent {
    enabled = true
  }

  disk {
    interface    = "virtio0"
    datastore_id = "ISOs"
    file_id      = proxmox_virtual_environment_file.coreos_qcow2.id
    size         = 32
  }

  cpu {
    cores = 2
    type  = "kvm64"
    units = 100
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  boot_order = ["virtio0", "ide0"]

  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.homelab_cluster_controlplane_ignition[count.index].rendered, ",", ",,")}'"

  lifecycle {
    ignore_changes = [started]
  }
}
