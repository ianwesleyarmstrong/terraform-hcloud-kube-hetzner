module "proxy" {
  count  = var.enable_proxy_node ? 1 : 0
  source = "./modules/proxy"


  providers = {
    hcloud = hcloud,
  }

  name                       = "${var.use_cluster_name_in_node_name ? "${var.cluster_name}-" : ""}proxy"
  base_domain                = var.base_domain
  ssh_keys                   = length(var.ssh_hcloud_key_label) > 0 ? concat([local.hcloud_ssh_key_id], data.hcloud_ssh_keys.keys_by_selector[0].ssh_keys.*.id) : [local.hcloud_ssh_key_id]
  ssh_port                   = var.ssh_port
  ssh_public_key             = var.ssh_public_key
  ssh_private_key            = var.ssh_private_key
  ssh_additional_public_keys = length(var.ssh_hcloud_key_label) > 0 ? concat(var.ssh_additional_public_keys, data.hcloud_ssh_keys.keys_by_selector[0].ssh_keys.*.public_key) : var.ssh_additional_public_keys
  #   firewall_ids               = [hcloud_firewall.k3s.id]
  #   placement_group_id = var.placement_group_disable ? 0 : hcloud_placement_group.agent[floor(each.value.index / 10)].id
  location       = var.proxy_node_location
  server_type    = var.proxy_node_type
  ipv4_subnet_id = hcloud_network_subnet.hcloud_network_subnet.all_others.id[0]

  # index 0 used for the proxy. Put your next machine at 1, if you need a similar non-k8s node.
  private_ipv4 = cidrhost(hcloud_network_subnet.hcloud_network_subnet.all_others.ip_range, 0)

  #   packages_to_install          = local.packages_to_install
  dns_servers                  = var.dns_servers
  k3s_registries               = var.k3s_registries
  opensuse_microos_mirror_link = var.opensuse_microos_mirror_link


  labels = local.labels

  proxy_registries = var.proxy_registries

  automatically_upgrade_os = var.automatically_upgrade_os

  depends_on = [
    hcloud_network_subnet.control_plane
  ]
}

locals {
  proxied_opensuse_microos_mirror_link = var.enable_proxy_node ? "http://${module.proxy[0].private_ipv4}/${basename(var.opensuse_microos_mirror_link)}" : var.opensuse_microos_mirror_link
  proxy_env                            = var.enable_proxy_node ? module.proxy[0].env_vars : {}
  proxy_preinstall_exec                = var.enable_proxy_node ? module.proxy[0].preinstall_exec : []
}
