# Load Balancing Azure Container Instances with Envoy
This repository contains a modified version of the scripts disscused in the article [Load Balancing Azure Container Instances with Envoy](https://medium.com/microsoftazure/load-balancing-azure-container-instances-with-envoy-4daf1f4c378c).

As of May 2022, the Azure Firewall resource is four times as expensive as an Azure Application Gateway. This version replaces the firewall with an app gateway, but leaves Envoy in place for now. Envoy shouldn't be necessary because app gateway supports the same load balancing capabilities. 

The checked-in configuration listens only on port 80. Should one add port 443 and the https protocol, more work will need to be done to conditionally include a TLS certificate. [This example](https://blog.xmi.fr/posts/tls-terraform-azure-lets-encrypt/) looks awesome. It could be added as a module to this project.

A gotcha to consider - Azure Container Instances don't have good DNS capabilities on private virtual networks. Any time an ACI restarts it will pick up a new IP address on the vnet. Any DNS entries previously configured in terraform will now be wrong. If this is a concern, you'll want to build a watcher of some kind to manage updates to the internal DNS entry for said container instances.