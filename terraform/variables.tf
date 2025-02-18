variable "subscription_id" {
    description = "Azure Subscription ID"
    type = string
}

variable "client_id" {
    description = "Azure Client ID"
    type = string
}

variable "client_secret" {
    description = "Azure Client Secret"
    type = string  
}

variable "tenant_id" {
    description = "Azure Tenant ID"
    type = string  
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}

variable "acr_username" {
  description = "The username for the Azure Container Registry"
  type        = string
}

variable "acr_password" {
  description = "The password for the Azure Container Registry"
  type        = string
}

variable "acr_email" {
  description = "The email for the Azure Container Registry"
  type        = string
}