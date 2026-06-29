variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint base URL"
  type        = string
  default     = "Proxmox Endpoin URL" # Removed /api2/json
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token"
  type        = string
  default     = "terraform-api@pam!terraform-api=sdhfkweh-3f34-e4a7-dsb2-cdsfe3431c3" #Don't try the same api token :) But Use the same format
  sensitive   = true
}

variable "vm_name_suffix" {
  description = "Suffix for the VM name"
  type        = string
  default     = "MCPServer"
}

variable "node" {
  description = "Proxmox node name where the VM will be created"
  type        = string
  default     = "proxmox"
}

variable "vmid" {
  description = "VM ID for the new cloned VM"
  type        = number
  default     = 200
}

variable "iso_path" {
  description = "URL to the ISO file to be used for VM creation"
  type        = string
  default     = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "cpucore" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory (in MB) for the VM"
  type        = number
  default     = 2048
}
