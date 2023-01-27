output "private_ipv4" {
  value       = var.private_ipv4
  description = "The private ip address at which cluster nodes can reach the proxy."
}

output "public_ipv4" {
  value       = module.proxy_server.ipv4_address
  description = "The private ip address at which cluster nodes can reach the proxy."
}

output "env_vars" {
  value = {
    "CONTAINERD_HTTP_PROXY" : "http://${var.private_ipv4}:3128",
    "CONTAINERD_HTTPS_PROXY" : "http://${var.private_ipv4}:3128",
    "NO_PROXY" : "127.0.0.0/8,10.0.0.0/8",
  }
  description = "The environment variables which you need to set on your node for it to use the proxy."
}

output "preinstall_exec" {
  value = [
    "counter=0; until curl http://${var.private_ipv4}:3128; do sleep 1; counter=$(( counter + 1 )); if [[ $counter -gt 120 ]]; then exit 1; fi; done",
    "curl http://${var.private_ipv4}:3128/ca.crt > /root/ca.crt",
    "trust anchor --store /root/ca.crt",
  ]
  description = "Run this on your node for it to use the proxy; this installs the proxy's certificate."
}
