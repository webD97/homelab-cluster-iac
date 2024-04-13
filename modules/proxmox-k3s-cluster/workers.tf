data "ct_config" "homelab_cluster_worker_ignition" {
  count  = var.worker_count
  strict = true
  content = templatefile("butane-templates/worker.yaml.tftpl", {
    ssh_authorized_key          = var.vm_ssh_authorized_key
    ssh_admin_username          = "admin"
    hostname                    = "${var.cluster_name}-worker-${count.index}"
    keymap                      = var.vm_keymap
    os_extensions_rpm_names     = []
    agent_token                 = "${random_password.agent_token.result}"
    controlplane_node_0_address = "https://${var.cluster_name}-control-0:6443"
    kubelet_config              = <<-EOF
      apiVersion: kubelet.config.k8s.io/v1beta1
      kind: KubeletConfiguration
      shutdownGracePeriod: 60s
      shutdownGracePeriodCriticalPods: 10s
    EOF
    k3s_download_url            = "https://github.com/k3s-io/k3s/releases/download/v1.29.3%2Bk3s1/k3s"
    k3s_download_hash           = "sha256-21b7542eeac71ffea09ee1efb9190bce7b77b8233ae13e12f3165c746c8559ee"
    zincati_update_strategy     = <<-EOF
      [updates]
      strategy = "periodic"

      [updates.periodic]
      time_zone = "localtime"

      [[updates.periodic.window]]
      days = [ "Sun" ]
      start_time = "02:00"
      length_minutes = 60
    EOF
  })
}


resource "proxmox_virtual_environment_vm" "homelab_cluster_worker" {
  count       = var.worker_count
  name        = "${var.cluster_name}-worker-${count.index}"
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
    cores = 4
  }

  memory {
    dedicated = 8192
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  boot_order = ["virtio0", "ide0"]

  kvm_arguments = "-fw_cfg 'name=opt/com.coreos/config,string=${replace(data.ct_config.homelab_cluster_worker_ignition[count.index].rendered, ",", ",,")}'"

  lifecycle {
    ignore_changes = [started, usb]
  }
}
