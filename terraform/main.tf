  data "azurerm_container_registry" "acr" {
  name                = "myacrcrowdbotics"
  resource_group_name = "acrRg1testjose"
}

# data azurerm_subscription "primary" {
#   subscription_id = var.subscription_id
# }

resource "azurerm_resource_group" "rg" {
   name     = "aks-resource-group"
   location = "eastus"
 }

resource "azurerm_user_assigned_identity" "uai" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "myaksidentity"
}

resource "azurerm_role_assignment" "acr_pull_uai" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/acrRg1testjose/providers/Microsoft.ContainerRegistry/registries/myacrcrowdbotics"
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
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
     type = "UserAssigned"
     identity_ids = ([azurerm_user_assigned_identity.uai.id])
   }
 }


resource "azurerm_role_assignment" "acr_pull_permission" {
  depends_on = [azurerm_kubernetes_cluster.myaks]

  scope                            =  "/subscriptions/${var.subscription_id}/resourceGroups/acrRg1testjose/providers/Microsoft.ContainerRegistry/registries/myacrcrowdbotics"
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.myaks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

resource "kubernetes_deployment" "main" {
  depends_on = [azurerm_kubernetes_cluster.myaks]

  metadata {
    name = "hello-world-app"
    labels = {
      app = "hello-world"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "hello-world"
      }
    }
    template {
      metadata {
        labels = {
          app = "hello-world"
        }
      }
      spec {

        container {
          name  = "hello-world-app"
          image = "myacrcrowdbotics.azurecr.io/hello-world-app:latest"
          port {
            container_port = 3000
          }
          image_pull_policy = "IfNotPresent"       
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.25"
              memory = "256Mi"
          }
        }
      }
    }
  }
  }
}

resource "kubernetes_service" "main" {
  depends_on = [kubernetes_deployment.main]
  metadata {
    name = "hello-world-service"
  }
  spec {
    selector = {
      app = "hello-world"
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}

