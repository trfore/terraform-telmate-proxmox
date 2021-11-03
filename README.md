# Terraform Telmate Proxmox

## Usage

Create a variable file, `*.tfvars`, and set the variable `proxmox_vm`.

```HCL
proxmox_vm = {
  "vm-example01" = {
    vm_id              = 100,
    hostname           = "vm-example01",
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
```

<details>
  <summary>Code Example: Clone Multiple VMs</summary>

```HCL
proxmox_vm = {
  "vm-example01" = {
    vm_id              = 101,
    hostname           = "vm-example01",
    target_node        = "pve",
    img_template       = "ubuntu20",
    vcpu               = "1",
    memory             = "1024",
    boot_disk_size     = "8G",     # str, required
    boot_disk_iothread = 0,        # int, required
    boot_disk_ssd      = 0,        # int
    boot_disk_discard  = "ignore", # "on" = ssd trim
    ci_ipv4_cidr       = "192.168.1.101/24",
    ci_ipv4_gateway    = "192.168.1.1",
    vnic_bridge        = "vmbr0",
    vlan_tag           = 1
  },
  "vm-example02" = {
    vm_id              = 102,
    hostname           = "vm-example01",
    target_node        = "pve",
    img_template       = "ubuntu20",
    vcpu               = "1",
    memory             = "1024",
    boot_disk_size     = "8G",     # str, required
    boot_disk_iothread = 0,        # int, required
    boot_disk_ssd      = 0,        # int
    boot_disk_discard  = "ignore", # "on" = ssd trim
    ci_ipv4_cidr       = "192.168.1.102/24",
    ci_ipv4_gateway    = "192.168.1.1",
    vnic_bridge        = "vmbr0",
    vlan_tag           = 1
  }
}
```

</details>

## CLI Usage

### Using Environment Variables

| Environment Variable    | Default | Description                                                    | Required | In-line Equivalent |
| ----------------------- | ------- | -------------------------------------------------------------- | -------- | ------------------ |
| TF_VAR_pve_token_id     |         | Proxmox API Token Name                                         | Yes      | `pve_token_id`     |
| TF_VAR_pve_token_secret |         | Proxmox API Token Value                                        | Yes      | `pve_token_secret` |
| TF_VAR_pve_api_url      |         | Proxmox API endpoint, e.g. `https://pve.example.com/api2/json` | Yes      | `pve_api_url`      |

```bash
$ export TF_VAR_pve_token_id='MY_TOKEN_VALUE'
$ export TF_VAR_pve_token_secret='MY_SECRET_VALUE'
$ export TF_VAR_pve_api_url=https://pve.example.com/api2/json

# create a terraform plan & apply it
$ terraform plan -out tfplan
$ terraform apply tfplan
```

### Using In-line Variables

```sh
# create a plan
terraform plan -var='pve_token_id=TOKEN' \
  -var='pve_token_secret=SECRET' \
  -var='pve_api_url=https://pve.example.com/api2/json' \
  -out tfplan

# apply the plan
terraform apply tfplan
```

## Using a Secrets Management Tool for Sensitive Variables

### Bitwarden

This example assumes you have a bitwarden **item** named `terraform-proxmox` with the following entries: a **proxmox
token** in the `username` field, **token secret** in the `password` field, and your **PVE API endpoint** in the first
`website` field. Additionally, you can store the DNS search domain value, e.g. `dns.example.com`, in the `note` field.

```sh
# login to bitwarden and export the session key
bw login
export BW_SESSION=$(bw unlock --raw)

# Set ENV Variables from Bitwarden Vault
export TF_VAR_pve_token_id=$(bw get username terraform-proxmox)
export TF_VAR_pve_token_secret=$(bw get password terraform-proxmox)
export TF_VAR_pve_api_url=$(bw get uri terraform-proxmox)

# create a terraform plan & apply it
terraform plan -out tfplan
terraform apply tfplan

# remove vm
terraform destroy
```

## State Storage

By default, Terraform stores state information in `terraform.tfstate` file in the local directory.
The module **does not** define a backend for the state file. Thus, terraform will use the default local
backend. For additional information on securing state files and configuring different backends, e.g. `s3`, see:

- [Terraform Developer - State]
- [Terraform Developer - State Backends]
- [Terraform Developer - Backend Configuration]

The S3 backend works with [MinIO] buckets, for example update the `terraform` block in `providers.tf` as follows:

```HCL
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.0"
    }
  }
  backend "s3" {
    bucket   = "terraform-bucket"
    key      = "terraform.tfstate"
    endpoint = "http://<MINIO-SERVER-IP>:9000"
    region   = "main"

    access_key = "MINIO_ACCESS_KEY"
    secret_key = "MINIO_SECRET_KEY"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

## Proxmox API Token

### Minimal Permission Requirements

- Note: the providers documentation suggest semi-broad permissions at the root path `/`, these modules works with fewer
  permissions and only needs the following paths: `/storage`, `/vms`

```bash
# create role
pveum role add TerraformUser -privs "Datastore.AllocateSpace Datastore.Audit VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.PowerMgmt"

# create group
pveum group add terraform-users

# add permissions
pveum acl modify /storage -group terraform-users -role TerraformUser

pveum acl modify /vms -group terraform-users -role TerraformUser

# create user 'terraform'
pveum useradd terraform@pve -groups terraform-users

# generate a token
pveum user token add terraform@pve token -privsep 0
```

## License

See [LICENSE](LICENSE) for more information.

## Author

Taylor Fore (<https://github.com/trfore>)

## References

### Terraform

- [Terraform]
- [Terraform - Docs]

### Terraform Provider - Proxmox

- [Telemate/Proxmox - Docs]
- [Telemate/Proxmox - Github]

### Terraform State File Management & Storage

- [Terraform Developer - State]
- [Terraform Developer - State Backends]
- [Terraform Developer - Backend Configuration]

### Secrets Management

- https://bitwarden.com/download/
- https://bitwarden.com/help/cli/
- https://github.com/bitwarden/clients
- https://www.vaultproject.io/
- https://developer.hashicorp.com/vault/docs

### Proxmox

- Proxmox VE API: https://pve.proxmox.com/wiki/Proxmox_VE_API
- Proxmox User Management: https://pve.proxmox.com/pve-docs/chapter-pveum.html

### Other

- [MinIO]

[Terraform]: https://www.terraform.io/
[Terraform - Docs]: https://developer.hashicorp.com/terraform
[Terraform Developer - State]: https://developer.hashicorp.com/terraform/language/state
[Terraform Developer - State Backends]: https://developer.hashicorp.com/terraform/language/state/backends
[Terraform Developer - Backend Configuration]: https://developer.hashicorp.com/terraform/language/settings/backends/configuration#available-backends
[Telemate/Proxmox - Docs]: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
[Telemate/Proxmox - Github]: https://github.com/Telmate/terraform-provider-proxmox
[MinIO]: https://min.io/
