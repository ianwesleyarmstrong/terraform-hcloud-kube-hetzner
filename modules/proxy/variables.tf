variable "name" {
  description = "Host name"
  type        = string
}

variable "base_domain" {
  description = "Base domain used for reverse dns"
  type        = string
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
}

variable "ssh_public_key" {
  description = "SSH public Key"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private Key"
  type        = string
}

variable "ssh_additional_public_keys" {
  description = "Additional SSH public Keys. Use them to grant other team members root access to your cluster nodes"
  type        = list(string)
  default     = []
}

variable "ssh_keys" {
  description = "List of SSH key IDs"
  type        = list(string)
  nullable    = true
}

variable "labels" {
  description = "Labels"
  type        = map(any)
  nullable    = true
}

variable "location" {
  description = "The server location"
  type        = string
}

variable "ipv4_subnet_id" {
  description = "The subnet id"
  type        = string
}

variable "server_type" {
  description = "The server type"
  type        = string
}

variable "dns_servers" {
  type        = list(string)
  description = "IP Addresses to use for the DNS Servers, set to an empty list to use the ones provided by Hetzner"
}

variable "k3s_registries" {
  default = ""
  type    = string
}

variable "automatically_upgrade_os" {
  type    = bool
  default = true
}

variable "opensuse_microos_mirror_link" {
  default = "https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-OpenStack-Cloud.qcow2"
  type    = string
}

variable "proxy_registries" {
  type        = string
  description = "Space separated list of registry hostnames, e.g. \"k8s.gcr.io registry.k8s.io gcr.io\"."
  default     = "k8s.gcr.io registry.k8s.io gcr.io ghcr.io quay.io registry.gitlab.com gitlab.com"
}
