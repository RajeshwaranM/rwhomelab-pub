packer {
  required_plugins {
    proxmox = {
      version = "1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type      = string
    sensitive = true
}

source "proxmox-iso" "rocky" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = "proxmox"

  # VM Details
  vm_id                = 9100
  vm_name              = "rocky-94-golden-template"
  template_description = "Rocky Linux 9.4 Preconfigured Golden Template"

  # Hardware Allocations 
  cores           = 2
  memory          = 4096
  cpu_type        = "host"
  scsi_controller = "virtio-scsi-pci"
  qemu_agent      = true

  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Cloud-Init Drive Configuration
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # Core OS Setup Sources
  iso_file         = "local:iso/Rocky-9.4-x86_64-boot.iso"
  iso_storage_pool = "local"
  unmount_iso      = true

  # Built-In HTTP Server Directives (Tells Packer to serve your 'files' folder)
  http_bind_address = "you machine ip address <Desktop or laptop>"
  http_directory    = "files"

# Defensive VNC Keystroke Automation
  boot_wait         = "10s"
  boot_key_interval = "150ms"
  boot_command = [
    "<up><wait>",
    "<tab><wait>",
    # FIXED: Replaced the placeholder function error with the clean standard Packer variable strings
    " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/ks.cfg ip=dhcp net.ifnames=0 biosdevname=0",
    "<enter>"
  ]

  # SSH Automation Credentials
  ssh_username = "<Username>"
  ssh_password = "<Password>"
  ssh_timeout  = "25m"
}

build {
  sources = ["source.proxmox-iso.rocky"]

  # Provisioner Stage: System Cleanups and Final Provisioning
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo systemctl enable qemu-guest-agent",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo dnf clean all",
      "sudo sync"
    ]
  }
}
