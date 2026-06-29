variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint base URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token"
  type        = string
  sensitive = true
}

variable "vm_name_suffix" {
  description = "Suffix for the VM name"
  type        = string
  default     = "ubuntutest"
}

variable "node" {
  description = "Proxmox node name where the VM will be created"
  type        = string
  default     = "proxmox"
}

variable "vmid" {
  description = "VM ID for the new cloned VM"
  type        = number
  default     = 500
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
