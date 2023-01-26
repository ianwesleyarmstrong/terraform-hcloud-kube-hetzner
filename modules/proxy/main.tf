locals {
  docker_compose_yaml = templatefile(
    "${path.module}/files/docker-compose.yaml.tftpl",
    {
      "proxy_registries" : var.proxy_registries,
    }
  )
  init_sh = templatefile(
    "${path.module}/scripts/init.sh.tftpl",
    {
      "opensuse_microos_mirror_link" : var.opensuse_microos_mirror_link,
    }
  )

  # ssh_agent_identity is not set if the private key is passed directly, but if ssh agent is used, the public key tells ssh agent which private key to use.
  # For terraforms provisioner.connection.agent_identity, we need the public key as a string.
  ssh_agent_identity = var.ssh_private_key == null ? var.ssh_public_key : null
  # shared flags for ssh to ignore host keys for all connections during provisioning.
  ssh_args = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o 'IdentitiesOnly yes'"

  # ssh_client_identity is used for ssh "-i" flag, its the private key if that is set, or a public key
  # if an ssh agent is used.
  ssh_client_identity = var.ssh_private_key == null ? var.ssh_public_key : var.ssh_private_key


}


resource "hcloud_firewall" "proxy_firewall" {
  name   = var.name
  labels = var.labels

  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    port      = "80"
    protocol  = "tcp"
    source_ips = [
      "10.0.0.0/8",
    ]
  }

  rule {
    direction = "in"
    port      = "3128"
    protocol  = "tcp"
    source_ips = [
      "10.0.0.0/8",
    ]
  }

}

module "proxy_server" {
  source = "../host"

  providers = {
    hcloud = hcloud,
  }

  name                         = var.name
  base_domain                  = var.base_domain
  ssh_keys                     = var.ssh_keys
  ssh_port                     = var.ssh_port
  ssh_public_key               = var.ssh_public_key
  ssh_private_key              = var.ssh_private_key
  ssh_additional_public_keys   = var.ssh_additional_public_keys
  firewall_ids                 = [hcloud_firewall.proxy_firewall.id]
  placement_group_id           = 0
  location                     = var.location
  server_type                  = var.server_type
  ipv4_subnet_id               = var.ipv4_subnet_id
  packages_to_install          = ["docker", "docker-compose"]
  dns_servers                  = var.dns_servers
  k3s_registries               = ""
  opensuse_microos_mirror_link = var.opensuse_microos_mirror_link

  labels = var.labels

  automatically_upgrade_os = var.automatically_upgrade_os

}

resource "null_resource" "init_proxy" {

  triggers = {
    "init_sh" : local.init_sh,
    "docker_compose_yaml" : local.docker_compose_yaml,
    "private_key" : var.ssh_private_key,
    "agent_identity" : local.ssh_agent_identity,
    "host" : module.proxy_server.ipv4_address,
    "port" : var.ssh_port,
  }


  connection {
    user           = "root"
    private_key    = self.triggers.private_key
    agent_identity = self.triggers.agent_identity
    host           = self.triggers.host
    port           = self.triggers.port
  }

  provisioner "file" {
    content     = self.triggers.docker_compose_yaml
    destination = "/root/docker-compose.yaml"
  }

  provisioner "file" {
    content     = self.triggers.init_sh
    destination = "/root/init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/sh /root/init.sh"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "cd /var/proxy-runtime && docker compose down"
    ]
  }

}
