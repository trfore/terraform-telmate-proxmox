terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pve_api_url
  pm_api_token_id     = var.pve_token_id
  pm_api_token_secret = var.pve_token_secret
}

resource "null_resource" "cloud_init" {
  connection {
    host        = var.pve_host_address
    port        = var.pve_host_port
    user        = var.pve_user
    password    = var.pve_password
    private_key = file(var.pve_ssh_key_private)
  }

  provisioner "file" {
    content     = file("${path.module}/files/vendor-data.yaml")
    destination = "/var/lib/vz/snippets/vendor-data.yaml"
  }
}

module "k3s_cluster" {
  source = "github.com/trfore/terraform-telmate-proxmox//modules/vm"

  for_each = tomap({
    "k3s-controller" = {
      id           = 210
      ipv4_cidr    = "192.168.1.210/24"
      ipv4_gateway = "192.168.1.1"
    },
    "k3s-node1" = {
      id           = 211
      ipv4_cidr    = null # Use DHCP
      ipv4_gateway = null # Use DHCP
    },
    "k3s-node2" = {
      id           = 212
      ipv4_cidr    = null # Use DHCP
      ipv4_gateway = null # Use DHCP
    },
  })

  node            = "pve"                                    # required
  vm_id           = each.value.id                            # required
  vm_name         = each.key                                 # optional
  template_name   = "ubuntu20"                               # required
  vcpu            = 2                                        # optional
  memory          = 4096                                     # optional
  ci_custom_data  = "vendor=local:snippets/vendor-data.yaml" # optional
  ci_ssh_key      = "~/.ssh/id_ed25519.pub"                  # optional, add SSH key to "default" user
  ci_ipv4_cidr    = each.value.ipv4_cidr                     # optional
  ci_ipv4_gateway = each.value.ipv4_gateway                  # optional
}

locals {
  controller_ip = module.k3s_cluster["k3s-controller"].public_ipv4
  agent_ips     = { for k, v in module.k3s_cluster : k => v.public_ipv4 if k != "k3s-controller" }
}

output "id" {
  value = { for k, v in module.k3s_cluster : k => v.id }
}

output "public_ipv4" {
  value = { for k, v in module.k3s_cluster : k => v.public_ipv4 }
}

output "controller_ip" {
  value = local.controller_ip
}

resource "random_string" "k3s_token" {
  length  = 64
  special = false
}

resource "null_resource" "controller" {
  connection {
    host = local.controller_ip
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_string.k3s_token.result} sh -"
    ]
  }
}

resource "null_resource" "agents" {
  for_each = local.agent_ips

  connection {
    host = each.value
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${local.controller_ip}:6443 K3S_TOKEN=${random_string.k3s_token.result} sh -"
    ]
  }
}
