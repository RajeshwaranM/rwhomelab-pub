# 1. Download the live Ubuntu 22.04.5 ISO directly to the Proxmox storage pool
resource "proxmox_download_file" "ubuntu_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.node
  url          = var.iso_path
}

# 2. Build the VM matching your cluster's working configuration profiles
resource "proxmox_virtual_environment_vm" "vm" {
  node_name   = var.node
  vm_id       = var.vmid
  name        = "VM-${var.vm_name_suffix}"
  description = "Created from ISO via Terraform"

  # Matches your working VM boot sequence perfectly
  boot_order = ["ide2", "scsi0"]

  cpu {
    cores = var.cpucore
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
    file_format  = "raw"
  }

  # Links directly to the new native download resource above
  cdrom {
    file_id   = proxmox_download_file.ubuntu_iso.id
    interface = "ide2"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
}
