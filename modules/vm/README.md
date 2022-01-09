# Telmate Proxmox VM

## Requirements

| Name        | Version  |
| ----------- | -------- |
| [terraform] | >= 1.0.0 |

## Providers

| Name              | Version  |
| ----------------- | -------- |
| [telmate proxmox] | >= 2.9.0 |

## Inputs

| Variable            | Default           | Type         | Description                                                                              | Required |
| ------------------- | ----------------- | ------------ | ---------------------------------------------------------------------------------------- | -------- |
| node                |                   | String       | Name of Proxmox node to provision VM on, e.g. `pve`                                      | **Yes**  |
| vm_id               |                   | Number       | ID number for new VM                                                                     | **Yes**  |
| vm_name             | `null`            | String       | Defaults to using PVE naming, e.g. `Copy-of-VM-<template_name>`                          | no       |
| description         | `null`            | String       | VM description                                                                           | no       |
| template_name       |                   | String       | Name of PVE template to clone, e.g. `ubuntu20`                                           | **Yes**  |
| full_clone          | `true`            | Boolean      | Create a full independent clone; setting to `false` will create a linked clone           | no       |
| provisioning_method | `cloud-init`      | String       | Telmate provider provisioning method - options: `ubuntu`, `centos`, or `cloud-init`      | no       |
| os_type             | `l26`             | String       | QEMU OS type, e.g. `l26` for Linux 6.x - 2.6 kernel                                      | no       |
| bios                | `seabios`         | String       | VM bios                                                                                  | no       |
| qemu_guest_agent    | `1`               | Number       | Enable QEMU guest agent                                                                  | no       |
| vcpu                | `1`               | Number       | Number of CPU cores                                                                      | no       |
| vcpu_type           | `host`            | String       | CPU type                                                                                 | no       |
| memory              | `1024`            | Number       | Memory size in `MiB`                                                                     | no       |
| numa                | `false`           | Boolean      | Emulate NUMA architecture                                                                | no       |
| scsihw              | `virtio-scsi-pci` | String       | Storage controller, e.g. `virtio-scsi-pci`                                               | no       |
| bootdisk            | `scsi0`           | String       | Boot disk                                                                                | no       |
| disks               | See below         | List(Object) | See [disks variables](#disks-variables) below                                            | no       |
| vnic_model          | `virtio`          | String       | Networking adapter model, e.g. `virtio`                                                  | no       |
| vnic_bridge         | `vmbr0`           | String       | Networking adapter dridge, e.g. `vmbr0`                                                  | no       |
| vlan_tag            | `1`               | Number       | Networking adapter VLAN tag                                                              | no       |
| ci_user             | `null`            | String       | Cloud-init 'default' user                                                                | no       |
| ci_ssh_key          | `null`            | String       | File path to SSH key for 'default' user, e.g. `~/.ssh/id_ed25519.pub`                    | no       |
| ci_dns_domain       | `null`            | String       | DNS domain name, e.g. `example.com`. Default `null` value will use PVE host settings     | no       |
| ci_dns_server       | `null`            | String       | DNS server, e.g. `192.168.1.1`. Default `null` value will use PVE host settings          | no       |
| ci_ipv4_cidr        | `null`            | String       | Default `null` will use `DHCP`, for a static address set CIDR, e.g. `192.168.1.254/24`   | no       |
| ci_ipv4_gateway     | `null`            | String       | Default `null` will use `DHCP`, for a static address add IP, e.g. `192.168.1.1`          | no       |
| ci_custom_data      | `null`            | String       | Add a custom cloud-init configuration file, e.g `vendor=local:snippets/vendor-data.yaml` | no       |

### Disks Variables

| Variable       | Default     | Type   | Description            | Required |
| -------------- | ----------- | ------ | ---------------------- | -------- |
| disk_interface | `scsi`      | String | Disk storage interface | no       |
| disk_slot      | `0`         | Number | Disk slot number       | no       |
| disk_storage   | `local-lvm` | String | Disk storage location  | no       |
| disk_size      | `8G`        | String | Disk size              | no       |
| disk_format    | `raw`       | String | Disk format            | no       |
| disk_cache     | `writeback` | String | Disk cache             | no       |
| disk_backup    | `0`         | Number | Enable disk backup     | no       |
| disk_iothread  | `0`         | Number | Enable IO threading    | no       |
| disk_ssd       | `1`         | Number | Enable SSD emulation   | no       |
| disk_discard   | `on`        | String | Enable TRIM            | no       |

Example:

```HCL
module "vm_example" {
  source = "github.com/trfore/terraform-telmate-proxmox/modules//vm"
  ...

  disks = [
    {
      disk_interface = "scsi"
      disk_slot      = 0
      disk_storage   = "local-lvm"
      disk_size      = "8G"
      disk_format    = "raw"
      disk_cache     = "writeback"
      disk_backup    = 1
    },
  ]
}
```

## Outputs

| Name          | Description     |
| ------------- | --------------- |
| `id`          | VM ID number    |
| `public_ipv4` | VM IPv4 address |

### Example

- [See example VM configurations](../../examples/vm/main.tf)

[terraform]: https://github.com/hashicorp/terraform
[telmate proxmox]: https://github.com/Telmate/terraform-provider-proxmox
