# Ubuntu Jammy Docker
# ---
# Packer Template to create an Ubuntu Server (jammy) on Proxmox

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

hclvariable "ssh_username" {
    type = string
}

variable "ssh_password" {
    type      = string
    sensitive = true
}
# Resource Definition for the VM Template
source "proxmox-iso" "ubuntu" {

    # * Proxmox Connection Settings
    proxmox_url = var.proxmox_api_url
    username    = var.proxmox_api_token_id
    token       = var.proxmox_api_token_secret #"${var.proxmox_api_token_secret}" string interpulaion
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true

    # * VM General Settings
    # ! This needs to match the name of the proxmox node the template will be on
    node  = "proxmox"
    # ! VM ID needs to be unique
    vm_id = "410"

    vm_name              = "ubuntu"
    template_description = "Ubuntu Server jammy Image preconfigured with docker"

    # * VM OS Settings
    boot_iso {
        iso_file         = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
        iso_storage_pool = "local"
    }

    # * VM System Settings
    qemu_agent = true

    # * VM BIOS Settings (EFI for UEFI boot)
    bios = "ovmf"

    efi_config {
        efi_storage_pool  = "local-lvm"
        efi_type          = "4m"
        pre_enrolled_keys = true
    }

    # * VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"
    disks {
        disk_size    = "20G"
        format       = "raw"
        storage_pool = "local-lvm"
        type         = "virtio"
    }

    # * VM CPU Settings
    cores = "2"

    # * VM Memory Settings
    memory = "2048"

    # * VM Network Settings
    network_adapters {
        model    = "virtio"
        bridge   = "vmbr0"
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init              = true
    cloud_init_storage_pool = "local-lvm"

    # PACKER Boot Commands (UEFI)
    boot_command = [
        "<wait5>",
        "e<wait>",
        "<down><down><down><end>",
        " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<wait>",
        "<f10><wait>"
    ]
    boot      = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory    = "./http"
    http_bind_address = "192.168.1.29"  # your Windows machine IP
    http_port_min     = 8802
    http_port_max     = 8802

    ssh_username = "${var.ssh_username}"
    ssh_password = "${var.ssh_password}"

    # Raise the timeout, when installation takes longer
    ssh_timeout          = "30m"
    ssh_handshake_attempts = 50
}

# Build Definition to create the VM Template
build {

    name    = "ubuntu"
    sources = ["source.proxmox-iso.ubuntu"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source      = "./files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
    }

    # Install Docker
    provisioner "shell" {
        inline = [
            "sudo apt-get update -y",
            "sudo apt-get install -y curl ca-certificates gnupg lsb-release",
            "sudo curl -sSL https://get.docker.com | bash",
            "sudo usermod -aG docker $(whoami)",
            "sudo apt-get install -y docker-compose"
        ]
    }
}
