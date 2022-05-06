output "this_name" {
  value       = azurerm_application_gateway.this.name
  description = "Created gateway name."
}

output "this_pips" {
  value       = azurerm_public_ip.pips[*].ip_address
  description = "Created public IPs."
}
