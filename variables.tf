# Sensitive Variables to Pass as Terrafrom CLI Args or ENV Vars
variable "pve_token_id" {
  description = "Proxmox API Token Name."
  sensitive   = true
}

variable "pve_token_secret" {
  description = "Proxmox API Token Value."
  sensitive   = true
}

# Sensitive Variables
variable "pve_api_url" {
  description = "Proxmox API Endpoint, e.g. 'https://pve.example.com/api2/json'."
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)^http[s]?://.*/api2/json$", var.pve_api_url))
    error_message = "Proxmox API Endpoint Invalid. Check URL - Scheme and Path required."
  }
}

variable "ssh_key_public" {
  description = "Public SSH Key for VM Host."
  default     = "~/.ssh/id_ed25519.pub"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)PRIVATE", var.ssh_key_public)) == false
    error_message = "ERROR Private SSH Key."
  }
}

variable "ci_dns_domain" {
  description = "Internal DNS Server, e.g. 'dns.example.com'."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.ci_dns_domain) != 0
    error_message = "DNS URL required."
  }
}

variable "ci_dns_server" {
  description = "Internal DNS nameserver, e.g. '192.168.1.1'."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.ci_dns_server) != 0
    error_message = "DNS nameserver IP required."
  }
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

# default Variables
variable "proxmox_vm" {
  description = "VM settings, hostname must be alphanumeric, may contain `-`."
  type        = map(any)
  default = {
    "vm-example" = {
      vm_id              = 100,
      hostname           = "vm-example",
      target_node        = "pve",
      img_template       = "ubuntu20",
      vcpu               = "1",
      memory             = "1024",
      boot_disk_size     = "8G",     # str, required
      boot_disk_iothread = 0,        # int, required
      boot_disk_ssd      = 0,        # int
      boot_disk_discard  = "ignore", # "on" = ssd trim
      ci_ipv4_cidr       = "192.168.1.100/24",
      ci_ipv4_gateway    = "192.168.1.1",
      vnic_bridge        = "vmbr0",
      vlan_tag           = 1
    }
  }
}
