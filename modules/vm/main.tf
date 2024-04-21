terraform {
  required_version = ">=1.3.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 3.0.0"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  target_node = var.node
  vmid        = var.vm_id
  name        = var.vm_name
  desc        = var.description
  clone       = var.template_name
  full_clone  = var.full_clone
  os_type     = var.provisioning_method
  qemu_os     = var.os_type
  bios        = var.bios
  agent       = var.qemu_guest_agent
  cores       = var.vcpu
  cpu         = var.vcpu_type
  memory      = var.memory
  numa        = var.numa
  scsihw      = var.scsihw
  bootdisk    = var.bootdisk

  dynamic "disk" {
    for_each = var.disks
    content {
      type     = disk.value.disk_interface
      slot     = disk.value.disk_slot
      storage  = disk.value.disk_storage
      size     = disk.value.disk_size
      format   = disk.value.disk_format
      cache    = disk.value.disk_cache
      backup   = disk.value.disk_backup
      iothread = disk.value.disk_iothread
      ssd      = disk.value.disk_ssd
      discard  = disk.value.disk_discard
    }
  }

  tablet = false

  network {
    model  = var.vnic_model
    bridge = var.vnic_bridge
    tag    = var.vlan_tag
  }

  # cloud-init config
  ciuser       = var.ci_user
  sshkeys      = (var.ci_ssh_key != null ? file("${var.ci_ssh_key}") : null)
  searchdomain = var.ci_dns_domain
  nameserver   = var.ci_dns_server
  ipconfig0    = (var.ci_ipv4_cidr != null ? "ip=${var.ci_ipv4_cidr},gw=${var.ci_ipv4_gateway}" : "ip=dhcp")
  cicustom     = var.ci_custom_data

  # block changing mac address on reapply
  # https://github.com/Telmate/terraform-provider-proxmox/issues/112/
  lifecycle {
    ignore_changes = [
      network
    ]
  }
}
