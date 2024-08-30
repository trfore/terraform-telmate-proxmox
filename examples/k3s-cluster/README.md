# Example Code

- This code will create a three node K3s cluster, the nodes are configured using the recommended `2` vcpus and `4096` MB
  of ram for a [small deployment]. The default network CNI (Flannel), datastore (sqlite3), and settings are used.
- Companion code to [the blog post (link)].

## Usage

```sh
# create a terraform plan
terraform plan \
  -var='pve_api_url=https://pve.example.com/api2/json' \
  -var='pve_api_token_id=TOKEN' \
  -var='pve_api_token_secret=SECRET' \
  -out tfplan

# build the cluster
terraform apply tfplan
```

## Links

- [K3s](https://k3s.io/)
- [K3s Docs](https://docs.k3s.io/)

[small deployment]: https://docs.k3s.io/installation/requirements#cpu-and-memory
[the blog post (link)]: https://trfore.com/posts/provisioning-proxmox-vms-with-terraform
