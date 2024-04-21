terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 3.0.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pve_api_url
  pm_api_token_id     = var.pve_token_id
  pm_api_token_secret = var.pve_token_secret
}

# Create Single Container
module "lxc_minimal_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/lxc"

  node                = "pve"                                                     # Required
  lxc_id              = 100                                                       # Required
  os_template         = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz" # Required
  os_type             = "ubuntu"                                                  # Optional, recommended
  user_ssh_key_public = "~/.ssh/id_ed25519.pub"                                   # Optional, recommended
}

output "id" {
  value = module.lxc_minimal_config.id
}

output "mac_address" {
  value = module.lxc_minimal_config.mac_address
}

# Create Multiple Containers
module "lxc_multiple_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/lxc"

  for_each = tomap({
    "lxc-example-01" = {
      id = 101
    },
    "lxc-example-02" = {
      id = 102
    },
  })

  node                = "pve"                                                     # Required
  lxc_id              = each.value.id                                             # Required
  lxc_name            = each.key                                                  # Optional
  os_template         = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz" # Required
  os_type             = "ubuntu"                                                  # Optional, recommended
  user_ssh_key_public = "~/.ssh/id_ed25519.pub"                                   # Optional, recommended
}

# Create Single LXC with Static IP Address
module "lxc_static_ip_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/lxc"

  node                = "pve"                                                     # Required
  lxc_id              = 103                                                       # Required
  lxc_name            = "lxc-example-static-ip"                                   # Optional
  description         = "terraform provisioned on ${timestamp()}"                 # Optional
  os_template         = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz" # Required
  os_type             = "ubuntu"                                                  # Optional, recommended
  user_ssh_key_public = "~/.ssh/id_ed25519.pub"                                   # Optional, recommended
  start_on_create     = true
  start_on_boot       = true
  startup_options     = "order=1,up=30,down=30"
  vlan_tag            = "1"
  ipv4_address        = "192.168.1.103/24"
  ipv4_gateway        = "192.168.1.1"
}

# Create Single LXC with Additional Mountpoints
module "vm_mountpoint_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/lxc"

  node                = "pve"                                                     # Required
  lxc_id              = 104                                                       # Required
  lxc_name            = "lxc-example-mountpoints"                                 # Optional
  os_template         = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz" # Required
  os_type             = "ubuntu"                                                  # Optional, recommended
  user_ssh_key_public = "~/.ssh/id_ed25519.pub"                                   # Optional, recommended
  mountpoint = [
    {
      mp         = "/mnt/local"
      mp_size    = "4G"
      mp_slot    = 0
      mp_key     = "0"
      mp_storage = "local-lvm"
      mp_volume  = null
      mp_backup  = true
    },
    {
      mp         = "/mnt/configs"
      mp_size    = "4G"
      mp_slot    = 1
      mp_key     = "1"
      mp_storage = "local-lvm"
    }
  ]
}
