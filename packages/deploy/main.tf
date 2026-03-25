terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.54"
    }
  }
}
variable "hcloud_token" {
  sensitive = true
}
variable "nixos_config_name" {
}
provider "hcloud" {
  token = var.hcloud_token
}
data "hcloud_ssh_key" "default" {
  name = "default"
}
resource "hcloud_server" "default" {
  name               = var.nixos_config_name
  server_type        = "cpx11"
  image              = "ubuntu-24.04"
  delete_protection  = true
  rebuild_protection = true
  ssh_keys = [
    data.hcloud_ssh_key.default.id
  ]
}
module "deploy" {
  count                  = 1
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = ".#nixosConfigurations.${var.nixos_config_name}.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.${var.nixos_config_name}.config.system.build.diskoScript"
  target_host            = hcloud_server.default.ipv4_address
}
resource "local_file" "ipv4_address" {
  content  = hcloud_server.default.ipv4_address
  filename = "${path.module}/prm/ipv4_address"
}
