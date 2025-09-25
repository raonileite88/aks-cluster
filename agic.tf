resource "null_resource" "enable_agic" {
  depends_on = [
    module.aks,
    azurerm_application_gateway.appgw
  ]

  provisioner "local-exec" {
    command = <<EOT
      az aks enable-addons \
        --resource-group ${module.aks.aks_rg} \
        --name ${module.aks.aks_name} \
        --addons ingress-appgw \
        --appgw-id ${azurerm_application_gateway.appgw.id}
    EOT
  }
}
