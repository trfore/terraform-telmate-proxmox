# simple clone of a proxmox template image (e.g. ubuntu-cloud)
resource "proxmox_vm_qemu" "proxmox_vm" {
  for_each    = var.proxmox_vm
  name        = each.value.hostname
  desc        = each.value.hostname
  vmid        = each.value.vm_id
  target_node = each.value.target_node
  clone       = each.value.img_template
  full_clone  = false
  os_type     = "cloud-init"
  memory      = each.value.memory
  cores       = each.value.vcpu
  agent       = 1
  numa        = true

  disk {
    type     = "scsi"
    storage  = "local-lvm"
    size     = each.value.boot_disk_size
    iothread = each.value.boot_disk_iothread
    ssd      = each.value.boot_disk_ssd
    discard  = each.value.boot_disk_discard
  }
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  tablet = false

  network {
    model  = "virtio"
    bridge = each.value.vnic_bridge
    tag    = each.value.vlan_tag
  }

  # cloud-init settings
  searchdomain = var.ci_dns_domain
  nameserver   = var.ci_dns_server
  sshkeys      = file("${var.ssh_key_public}")
  ipconfig0    = "ip=${each.value.ci_ipv4_cidr},gw=${each.value.ci_ipv4_gateway}"

  # block changing mac address on reapply
  # https://github.com/Telmate/terraform-provider-proxmox/issues/112/
  lifecycle {
    ignore_changes = [
      network
    ]
  }
}
