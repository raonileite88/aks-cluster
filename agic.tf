resource "null_resource" "enable_agic" {
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_application_gateway.appgw
  ]

  provisioner "local-exec" {
    command = <<EOT
      az aks enable-addons \
        --resource-group ${azurerm_kubernetes_cluster.aks.resource_group_name} \
        --name ${azurerm_kubernetes_cluster.aks.name} \
        --addons ingress-appgw \
        --appgw-id ${azurerm_application_gateway.appgw.id}
    EOT
  }
}
