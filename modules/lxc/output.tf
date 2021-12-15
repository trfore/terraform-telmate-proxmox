output "id" {
  description = "Container ID"
  value       = proxmox_lxc.lxc.id
}

output "mac_address" {
  description = "Container MAC Address"
  value       = proxmox_lxc.lxc.network[0].hwaddr
}
