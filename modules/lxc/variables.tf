## LXC Variables
variable "node" {
  description = "Name of Proxmox node to provision LXC on, e.g. `pve`."
  type        = string
}

variable "lxc_id" {
  description = "ID number for new LXC."
  type        = number
}

variable "lxc_name" {
  description = "LXC name, must be alphanumeric (may contain dash: `-`). Defaults to using PVE naming, e.g. `CT<LXC_ID>`."
  type        = string
  default     = null
}

variable "description" {
  description = "LXC description."
  type        = string
  default     = null
}

variable "os_template" {
  description = "Template for LXC."
  type        = string
}

variable "os_type" {
  description = "Container OS specific setup, uses setup scripts in `/usr/share/lxc/config/<ostype>.common.conf`."
  type        = string
  default     = "unmanaged"
  validation {
    condition     = contains(["alpine", "archlinux", "centos", "debian", "devuan", "fedora", "gentoo", "nixos", "opensuse", "ubuntu", "unmanaged"], var.os_type)
    error_message = "Invalid OS type setting."
  }
}

variable "unprivileged" {
  description = "Set container to unprivileged."
  type        = bool
  default     = true
}

variable "vcpu" {
  description = "Number of CPU cores."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory size in `MiB`."
  type        = string
  default     = "512"
}

variable "memory_swap" {
  description = "Memory swap size in `MiB`."
  type        = string
  default     = "512"
}

### Startup Variables
variable "start_on_boot" {
  description = "Start container on PVE boot."
  type        = bool
  default     = false
}

variable "startup_options" {
  description = "Startup and shutdown options, e.g. `order=1,up=30,down=30`"
  type        = string
  default     = null
}

variable "start_on_create" {
  description = "Start container after creation."
  type        = bool
  default     = false
}

### Disk Variables
variable "disk_storage" {
  description = "Disk storage location."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  type    = string
  default = "8G"
}

variable "mountpoint" {
  type = list(object({
    mp         = string
    mp_size    = string
    mp_slot    = number
    mp_key     = string
    mp_storage = string
    mp_volume  = optional(string)
    mp_backup  = optional(bool)
    }
  ))
  default = null
}

### Network Variables
variable "vnic_name" {
  description = "Networking adapter name."
  type        = string
  default     = "eth0"
}

variable "vnic_bridge" {
  description = "Networking adapter bridge, e.g. `vmbr0`."
  type        = string
  default     = "vmbr0"
}

variable "vlan_tag" {
  description = "Networking adapter VLAN tag."
  type        = number
  default     = 1
}

variable "ipv4_address" {
  description = "Defaults to DHCP, for static IPv4 address set CIDR."
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "Defaults to DHCP, for static IPv4 gateway set IP address."
  type        = string
  default     = null
}

variable "ipv6_address" {
  description = "Defaults to DHCP, for static IPv6 address set CIDR."
  type        = string
  default     = "dhcp"
}

variable "ipv6_gateway" {
  description = "Defaults to DHCP, for static IPv6 gateway set IP address."
  type        = string
  default     = null
}

variable "dns_domain" {
  description = "Defaults to using PVE host setting."
  type        = string
  default     = null
}

variable "dns_server" {
  description = "Defaults to using PVE host setting."
  type        = string
  default     = null
}

## Default User Variables
variable "user_ssh_key_public" {
  description = "Public SSH Key for LXC user."
  default     = null
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)PRIVATE", var.user_ssh_key_public)) == false
    error_message = "Error: Private SSH Key."
  }
}

variable "user_password" {
  description = "Password for LXC user."
  type        = string
  sensitive   = true
  default     = null
}
