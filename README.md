# Terraform Telmate Proxmox Modules

This repository contains modules and examples for deploying linux containers and virtual machines on [Proxmox](https://www.proxmox.com/)
using [Terraform](https://terraform.io) with the [Telmate Proxmox Provider](https://github.com/Telmate/terraform-provider-proxmox).

## Requirements

| Name              | Version  |
| ----------------- | -------- |
| [terraform]       | >= 1.3.0 |
| [proxmox]         | >= 8.0   |
| [telmate proxmox] | >= 3.0.0 |

## Telmate Provider: Build the Plugin

Currently, the revised [`disk` block](https://github.com/Telmate/terraform-provider-proxmox/issues/986) is only
available in the ['new-disk' branch](https://github.com/telmate/terraform-provider-proxmox/tree/new-disk). To build the
plugin, you will need to have [Go](https://golang.org/) and [GNU make](https://www.gnu.org/software/make/) installed on
your machine. After that, you can run the following commands to build and install the plugin:

```bash
# clone the repo
git clone https://github.com/Telmate/terraform-provider-proxmox
cd terraform-provider-proxmox
# change the branch
git checkout new-disk

# build the binary
make
```

To use the binary, you will need to move it into the plugins directory, `~/.terraform.d/plugins` (Unix) or
`%APPDATA%\terraform.d\plugins` (Windows). For practicality's sake, the following code will name it `3.0.1`, however,
this is not an official release.

```bash
# move the binary into the terraform plugins directory
VERSION='3.0.1'

mkdir -p ~/.terraform.d/plugins/registry.terraform.io/telmate/proxmox/"${VERSION}"/linux_amd64/

cp bin/terraform-provider-proxmox ~/.terraform.d/plugins/registry.terraform.io/telmate/proxmox/"${VERSION}"/linux_amd64/terraform-provider-proxmox_v"${VERSION}"
```

Update your terraform files to use the new binary:

```HCL
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1"
    }
  }
}
```

And to use this repo's modules, set the source to:

```HCL
module "vm" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/vm?ref=v3"
  ...
}

module "lxc" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/lxc?ref=v3"
  ...
}
```

## Modules

### LXC Container Module

<details>
  <summary>Code Example: Create A Linux Container</summary>

```HCL
module "single_lxc" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/lxc"

  node                = "pve"
  lxc_id              = 100
  lxc_name            = "lxc-example"
  description         = "terraform provisioned on ${timestamp()}"
  os_template         = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  os_type             = "ubuntu"
  user_ssh_key_public = "~/.ssh/id_ed25519.pub"
  vlan_tag            = "1"
  ipv4_address        = "192.168.1.100/24"
  ipv4_gateway        = "192.168.1.1"
}
```

</details>

<details>
  <summary>Code Example: Create Multiple Linux Containers</summary>

```HCL
module "multiple_lxc" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/lxc"

  for_each = tomap({
    "lxc-example-01" = {
      id = 101
    },
    "lxc-example-02" = {
      id = 102
    },
  })

  node                = "pve"
  lxc_id              = each.value.id
  lxc_name            = each.key
  os_template         = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  os_type             = "ubuntu"
  user_ssh_key_public = "~/.ssh/id_ed25519.pub"
}
```

</details>

- See [`examples/lxc`](./examples/lxc/main.tf) for full working examples.
- See [`modules/lxc/README.md`](./modules/lxc/README.md#inputs) for a list of variables.

### VM Module

<details>
  <summary>Code Example: Clone A Single VM</summary>

```HCL
module "single_vm" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/vm"

  node          = "pve"
  vm_id         = 100
  vm_name       = "vm-example"
  template_name = "ubuntu20"
  ci_ssh_key    = "~/.ssh/id_ed25519.pub"
}
```

</details>

<details>
  <summary>Code Example: Clone Multiple VMs</summary>

```HCL
module "multiple_vm" {
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

  node          = "pve"
  vm_id         = each.value.id
  vm_name       = each.key
  template_name = each.value.template
  ci_ssh_key    = "~/.ssh/id_ed25519.pub"
}
```

</details>

- See [`examples/vm`](./examples/vm/main.tf) for full working examples.
- See [`modules/vm/README.md`](./modules/vm/README.md#inputs) for a list of variables.

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
The modules **do not** define a backend for the state file. Thus, terraform will use the default local
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

### Permission Requirements

Note: Provider requires broad permissions at the root path `/`.

```bash
# create role
pveum role add TerraformUser -privs "Datastore.AllocateSpace Datastore.Audit \
  Pool.Allocate SDN.Use Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit \
  VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk \
  VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options \
  VM.Migrate VM.Monitor VM.PowerMgmt"

# create group
pveum group add terraform-users

# add permissions
pveum acl modify / -group terraform-users -role TerraformUser

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

- [Companion blog post](https://trfore.com/posts/provisioning-proxmox-vms-with-terraform)

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

- <https://bitwarden.com/download/>
- <https://bitwarden.com/help/cli/>
- <https://github.com/bitwarden/clients>
- <https://www.vaultproject.io/>
- <https://developer.hashicorp.com/vault/docs>

### Proxmox

- Proxmox VE API: <https://pve.proxmox.com/wiki/Proxmox_VE_API>
- Proxmox User Management: <https://pve.proxmox.com/pve-docs/chapter-pveum.html>

### Other

- [MinIO]

[proxmox]: https://www.proxmox.com/en/
[telmate proxmox]: https://github.com/Telmate/terraform-provider-proxmox
[Terraform]: https://www.terraform.io/
[Terraform - Docs]: https://developer.hashicorp.com/terraform
[Terraform Developer - State]: https://developer.hashicorp.com/terraform/language/state
[Terraform Developer - State Backends]: https://developer.hashicorp.com/terraform/language/state/backends
[Terraform Developer - Backend Configuration]: https://developer.hashicorp.com/terraform/language/settings/backends/configuration#available-backends
[Telemate/Proxmox - Docs]: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
[Telemate/Proxmox - Github]: https://github.com/Telmate/terraform-provider-proxmox
[MinIO]: https://min.io/
