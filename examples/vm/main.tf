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

# Create Single VM
module "vm_minimal_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/vm"

  node          = "pve"                   # required
  vm_id         = 100                     # required
  vm_name       = "vm-example-minimal"    # optional
  template_name = "ubuntu20"              # required
  ci_ssh_key    = "~/.ssh/id_ed25519.pub" # optional, add SSH key to "default" user
}

output "id" {
  value = module.vm_minimal_config.id
}

output "public_ipv4" {
  value = module.vm_minimal_config.public_ipv4
}

# Create Multiple VMs
module "vm_multiple_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/vm"

  for_each = tomap({
    "vm-multiple-01" = {
      id       = 101
      template = "debian10"
    },
    "vm-multiple-02" = {
      id       = 102
      template = "ubuntu20"
    },
  })

  node          = "pve"                   # required
  vm_id         = each.value.id           # required
  vm_name       = each.key                # optional
  template_name = each.value.template     # required
  ci_ssh_key    = "~/.ssh/id_ed25519.pub" # optional, add SSH key to "default" user
}

output "id_multiple_vms" {
  value = { for k, v in module.vm_multiple_config : k => v.id }
}

output "public_ipv4_multiple_vms" {
  value = { for k, v in module.vm_multiple_config : k => v.public_ipv4 }
}

# Create Single VM with Additional Disks
module "vm_disk_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/vm"

  node          = "pve"                   # required
  vm_id         = 103                     # required
  vm_name       = "vm-example-disks"      # optional
  template_name = "ubuntu20"              # required
  ci_ssh_key    = "~/.ssh/id_ed25519.pub" # optional, add SSH key to "default" user
  disks = [
    {
      disk_slot    = "scsi0" # default cloud image boot drive
      disk_storage = "local-lvm"
      disk_size    = "8G"
      disk_format  = "raw"
      disk_cache   = "writeback"
      disk_backup  = true
      disk_ssd     = true
      disk_discard = true
    },
    {
      disk_slot    = "scsi1" # example add extra disk
      disk_storage = "local-lvm"
      disk_size    = "4G"
      disk_format  = "raw"
      disk_cache   = "writeback"
      disk_ssd     = true
      disk_discard = true
    },
  ]
}

# Create Single VM using UEFI
module "vm_uefi_config" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/vm"

  node          = "pve"                   # required
  vm_id         = 104                     # required
  vm_name       = "vm-example-uefi"       # optional
  template_name = "ubuntu20"              # required
  bios          = "ovmf"                  # optional, set UEFI bios
  ci_ssh_key    = "~/.ssh/id_ed25519.pub" # optional, add SSH key to "default" user
}
