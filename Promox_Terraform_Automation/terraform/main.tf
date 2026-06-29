resource "proxmox_virtual_environment_vm" "vm" {
  node_name   = var.node
  vm_id       = var.vmid
  name        = "VM-${var.vm_name_suffix}"
  description = "Cloned from Ubuntu Packer template"

  # Clone from your Packer template (ID 410)
  clone {
    vm_id = 410
    full  = true
  }

  # This triggers cloud-init to run on first boot
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  cpu {
    cores = var.cpucore
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }
}
