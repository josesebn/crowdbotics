  resource "azurerm_resource_group" "rg" {
   name     = "aks-resource-group"
   location = "eastus"
 }

 resource "azurerm_kubernetes_cluster" "myaks" {
   name                = "TestAKSCluster"
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name
   dns_prefix          = "myakscluster"

   default_node_pool {
     name       = "default"
     node_count = 2
     vm_size    = "Standard_DS2_v2"
   }

   identity {
     type = "SystemAssigned"
   }
 }
