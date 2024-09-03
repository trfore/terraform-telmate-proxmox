## VM Variables
variable "node" {
  description = "Name of Proxmox node to provision VM on, e.g. 'pve'."
  type        = string
}

variable "vm_id" {
  description = "ID number for new VM."
  type        = number
}

variable "vm_name" {
  description = "VM name, must be alphanumeric (may contain dash: `-`). Defaults to using PVE naming, e.g. 'Copy-of-VM-<template_name>'."
  type        = string
  default     = null
}

variable "description" {
  description = "VM description."
  type        = string
  default     = null
}

variable "template_name" {
  description = "Name of PVE template to clone, e.g. 'ubuntu20'."
  type        = string
}

variable "full_clone" {
  description = "Create a full independent clone; setting to 'false' will create a linked clone."
  type        = bool
  default     = true
}

variable "provisioning_method" {
  description = "Telmate provider provisioning method - options: 'ubuntu', 'centos', or 'cloud-init'."
  type        = string
  default     = "cloud-init"
  validation {
    condition     = contains(["ubuntu", "centos", "cloud-init"], var.provisioning_method)
    error_message = "Invalid provisioning method! Valid options: 'ubuntu', 'centos', or 'cloud-init'."
  }
}

variable "os_type" {
  description = "QEMU OS type, e.g. 'l26' for Linux 6.x - 2.6 kernel."
  type        = string
  default     = "l26"
}

variable "bios" {
  description = "VM bios."
  type        = string
  default     = "seabios"
  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "Invalid bios setting! Valid options: 'seabios' or 'ovmf'."
  }
}

variable "qemu_guest_agent" {
  description = "Enable QEMU guest agent."
  type        = number
  default     = 1
}

variable "vcpu" {
  description = "Number of CPU cores."
  type        = number
  default     = 1
}

variable "vcpu_type" {
  description = "CPU type."
  type        = string
  default     = "host"
}

variable "memory" {
  description = "Memory size in MiB."
  type        = number
  default     = 1024
}

variable "numa" {
  description = "Emulate NUMA architecture."
  type        = bool
  default     = false
}

variable "tablet" {
  description = "Enable tablet for pointer."
  type        = bool
  default     = false
}

### Disk Variables
variable "scsihw" {
  description = "Storage controller, e.g. 'virtio-scsi-pci'."
  type        = string
  default     = "virtio-scsi-pci"
}

variable "bootdisk" {
  description = "Boot disk."
  type        = string
  default     = "scsi0"
}

variable "disks" {
  description = "Terraform object with disk configurations."
  type = list(object({
    disk_type     = optional(string, "disk")
    disk_slot     = optional(string, "scsi0")
    disk_storage  = optional(string, "local-lvm")
    disk_size     = optional(string, "8G")
    disk_format   = optional(string, "raw")
    disk_cache    = optional(string, "writeback")
    disk_backup   = optional(bool, false)
    disk_iothread = optional(bool, false)
    disk_ssd      = optional(bool, true)
    disk_discard  = optional(bool, true)
    }
  ))
  default = [{
    disk_type     = "disk"
    disk_slot     = "scsi0"
    disk_storage  = "local-lvm"
    disk_size     = "8G"
    disk_format   = "raw"
    disk_cache    = "writeback"
    disk_backup   = false
    disk_iothread = false
    disk_ssd      = true
    disk_discard  = true
  }]
}

variable "efi_disk_storage" {
  description = "EFI disk storage location."
  type        = string
  default     = "local-lvm"
}

variable "efi_disk_type" {
  description = "EFI disk OVMF firmware version."
  type        = string
  default     = "4m"
}

### Network Variables
variable "vnic_model" {
  description = "Networking adapter model, e.g. 'virtio'."
  type        = string
  default     = "virtio"
}

variable "vnic_bridge" {
  description = "Networking adapter dridge, e.g. 'vmbr0'."
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "Networking adapter VLAN tag."
  type        = number
  default     = 1
}

### Cloud-init Variables
variable "ci_drive_slot" {
  description = "Slot for cloud-init config drive, e.g. `ide2`."
  type        = string
  default     = "ide2"
}

variable "ci_drive_storage" {
  description = "Storage location for cloud-init config drive, e.g. `local-lvm`."
  type        = string
  default     = "local-lvm"
}

variable "ci_user" {
  description = "Cloud-init 'default' user."
  type        = string
  default     = null
}

variable "ci_password" {
  description = "Cloud-init 'default' user password."
  type        = string
  default     = null
}

variable "ci_upgrade_packages" {
  description = "Upgrade packages via Cloud-init."
  type        = bool
  default     = true
}

variable "ci_ssh_key" {
  description = "File path to SSH key for 'default' user, e.g. '~/.ssh/id_ed25519.pub'."
  type        = string
  default     = null
}

variable "ci_dns_domain" {
  description = "DNS domain name, e.g. 'example.com'. Default 'null' value will use PVE host settings."
  type        = string
  default     = null
}

variable "ci_dns_server" {
  description = "DNS server, e.g. '192.168.1.1'. Default 'null' value will use PVE host settings."
  type        = string
  default     = null
}

variable "ci_ipv4_cidr" {
  description = "Default 'null' value will use DHCP.For a static address set CIDR, e.g. '192.168.1.2/24'."
  type        = string
  default     = null
}

variable "ci_ipv4_gateway" {
  description = "Default 'null' value will use DHCP. For a static address set IP, e.g. '192.168.1.1'."
  type        = string
  default     = null
}

variable "ci_custom_data" {
  description = "Add a custom cloud-init configuration file, e.g 'vendor=local:snippets/vendor-data.yaml'."
  type        = string
  default     = null
}
