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

 provider "kubernetes" {
  host = azurerm_kubernetes_cluster.myaks.kube_config.0.host
  client_certificate = base64decode(azurerm_kubernetes_cluster.myaks.kube_config.0.client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.myaks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.myaks.kube_config.0.cluster_ca_certificate)
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
        # image_pull_secrets {
        #   name = kubernetes_secret.acr_secret.metadata.0.name
        # }
        container {
          name  = "hello-world-app"
          image = "myacrcrowdbotics.azurecr.io/hello-world-app:latest"
          port {
            container_port = 3000
          }
          image_pull_policy = "Always"       
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

