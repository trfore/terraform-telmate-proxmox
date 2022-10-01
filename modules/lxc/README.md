# Telmate LXC Module

## Requirements

| Name        | Version  |
| ----------- | -------- |
| [terraform] | >= 1.3.0 |

## Providers

| Name              | Version  |
| ----------------- | -------- |
| [telmate proxmox] | >= 2.9.0 |

## Inputs

### LXC Variables

| Variable            | Default     | Type    | Description                                                                                      | Required |
| ------------------- | ----------- | ------- | ------------------------------------------------------------------------------------------------ | -------- |
| node                |             | String  | Name of Proxmox node to provision LXC on, e.g. `pve`                                             | **Yes**  |
| lxc_id              |             | Number  | ID number for new LXC                                                                            | **Yes**  |
| lxc_name            | `null`      | String  | Defaults to using PVE naming, e.g. `CT<LXC_ID>`                                                  | no       |
| description         | `null`      | String  | LXC description                                                                                  | no       |
| os_template         |             | String  | Template for LXC, e.g. `local:vztmpl/ubuntu.tar.gz`                                              | **Yes**  |
| os_type             | `unmanaged` | String  | Container OS specific setup, uses setup scripts in `/usr/share/lxc/config/<os_type>.common.conf` | no       |
| unprivileged        | `true`      | Boolean | Set container to unprivileged                                                                    | no       |
| vcpu                | `1`         | String  | Number of CPU cores                                                                              | no       |
| memory              | `512`       | String  | Memory size in `MiB`                                                                             | no       |
| memory_swap         | `512`       | String  | Memory swap size in `MiB`                                                                        | no       |
| disk_storage        | `local-lvm` | String  | Disk storage location                                                                            | no       |
| disk_size           | `8G`        | String  | Disk size                                                                                        | no       |
| user_ssh_key_public | `null`      | String  | File path to public SSH key for LXC user, e.g. `~/.ssh/id_ed25519.pub`                           | no       |
| user_password       | `null`      | String  | Password for LXC user                                                                            | no       |
| start_on_boot       | `false`     | Boolean | Start container on PVE boot                                                                      | no       |
| startup_options     | `null`      | String  | Startup and shutdown options, e.g. `order=1,up=30,down=30`                                       | no       |
| start_on_create     | `false`     | Boolean | Start container after creation                                                                   | no       |

### Network Variables

| Variable     | Default | Type   | Description                                              | Required |
| ------------ | ------- | ------ | -------------------------------------------------------- | -------- |
| vnic_name    | `eth0`  | String | Networking adapter name                                  | no       |
| vnic_bridge  | `vmbr0` | String | Networking adapter bridge                                | no       |
| vlan_tag     | `1`     | String | Network adapter VLAN tag                                 | no       |
| ipv4_address | `dhcp`  | String | Defaults to DHCP, for static IPv4 address set CIDR       | no       |
| ipv4_gateway | `null`  | String | Defaults to DHCP, for static IPv4 gateway set IP address | no       |
| ipv6_address | `dhcp`  | String | Defaults to DHCP, for static IPv6 address set CIDR       | no       |
| ipv6_gateway | `null`  | String | Defaults to DHCP, for static IPv6 gateway set IP address | no       |
| dns_domain   | `null`  | String | Defaults to using PVE host setting                       | no       |
| dns_server   | `null`  | String | Defaults to using PVE host setting                       | no       |

### Mount Point Variables

| Variable   | Default      | Type         | Description                                                              | Required |
| ---------- | ------------ | ------------ | ------------------------------------------------------------------------ | -------- |
| mountpoint | `null`       | List(Object) | Default will not create mount point, see example below for creating ones | no       |
| mp         | `/mnt/local` | String       | Mount point path inside container, e.g. `/mnt/local`                     | no       |
| mp_size    | `4G`         | String       | PVE disk size, e.g. `4G`                                                 | no       |
| mp_slot    | `0`          | Number       | PVE disk slot for mount point, e.g `0`                                   | no       |
| mp_key     | `0`          | String       | PVE disk slot for mount point, e.g. `"0"`                                | no       |
| mp_storage | `local-lvm`  | String       | PVE storage backend, e.g. `local-lvm`                                    | no       |
| mp_volume  | `null`       | String       | Volume, device or directory to mount into the container                  | no       |
| mp_backup  | `false`      | Boolean      | Include mount point in PVE backups                                       | no       |

Example:

```HCL
module "lxc_mountpoint_config" {
  source = "github.com/trfore/terraform-telmate-proxmox/modules//lxc"
  ...

  mountpoint = [
    {
      mp         = "/mnt/local"
      mp_size    = "4G"
      mp_slot    = 0
      mp_key     = "0"
      mp_storage = "local-lvm"
      mp_backup  = true
    },
  ]
}
```

## Outputs

| Name          | Description           |
| ------------- | --------------------- |
| `id`          | Container ID          |
| `mac_address` | Container MAC address |

## Examples

- [See example LXC configurations](../../examples/lxc/main.tf)

[terraform]: https://github.com/hashicorp/terraform
[telmate proxmox]: https://github.com/Telmate/terraform-provider-proxmox
