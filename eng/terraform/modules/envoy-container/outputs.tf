output "this_ip" {
  value       = azurerm_container_group.this.ip_address
  description = "IP address of the created container group."
}

output "this_fqdn" {
  value       = azurerm_container_group.this.fqdn
  description = "FQDN of the container group, derived from dns_label. dns_label is not supported on virtual networks, so we'll see if this works at all."
}