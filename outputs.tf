output "instance_IPv4" {
  description = "IPv4 of the PVE instances"
  value       = values(proxmox_vm_qemu.proxmox_vm)[*].default_ipv4_address
}
