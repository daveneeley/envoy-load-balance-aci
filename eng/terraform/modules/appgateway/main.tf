resource "azurerm_public_ip" "pips" {
  count               = var.pips_count
  name                = "pip-${var.deployment_name}${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

#&nbsp;sinced$ these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "beap-${var.deployment_name}"
  frontend_port_name             = "feport-${var.deployment_name}"
  frontend_ip_configuration_name = "feip-${var.deployment_name}"
  http_setting_name              = "be-htst-${var.deployment_name}"
  listener_name                  = "httplstn-${var.deployment_name}"
  request_routing_rule_name      = "rqrt-${var.deployment_name}"
  redirect_configuration_name    = "rdrcfg-${var.deployment_name}"
}

resource "azurerm_application_gateway" "this" {
  name                = "ag-${var.deployment_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gwip-${var.deployment_name}"
    subnet_id = var.subnet_id
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    iterator = port
    content {
      name = "${local.frontend_port_name}-${port.value.port}"
      port = port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = azurerm_public_ip.pips
    iterator = pip
    content {
      name                 = substr(base64encode(pip.value.id), 0, 15)
      public_ip_address_id = pip.value.id
    }
  }

  dynamic "http_listener" {
    for_each = setproduct(azurerm_public_ip.pips, var.frontend_ports)
    iterator = cartesian
    content {
      name                           = "${local.listener_name}-${cartesian.key}"
      frontend_ip_configuration_name = substr(base64encode(cartesian.value[0].id), 0, 15)
      frontend_port_name             = "${local.frontend_port_name}-${cartesian.value[1].port}"
      protocol                       = cartesian.value[1].protocol
    }
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = var.backend_pool_fqdns
  }

  dynamic "backend_http_settings" {
    for_each = var.frontend_ports
    iterator = port
    content {
      name                  = "${local.http_setting_name}-${port.value.port}"
      cookie_based_affinity = "Disabled"
      port                  = port.value.port
      protocol              = port.value.protocol
      request_timeout       = 60
    }
  }

  dynamic "request_routing_rule" {
    for_each = setproduct(azurerm_public_ip.pips, var.frontend_ports)
    iterator = cartesian
    content {
      name                       = "${local.request_routing_rule_name}-${cartesian.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${local.listener_name}-${cartesian.key}"
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = "${local.http_setting_name}-${cartesian.value[1].port}"
    }
  }
}
