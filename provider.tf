terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
  subscription_id = "2416ed65-48a3-42a0-a8a0-af8d4ccd1157"
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.kubernetes.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.kubernetes.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.cluster_ca_certificate)
  }
}

provider "vault" {
  address = "http://${data.kubernetes_service.vault.status[0].load_balancer[0].ingress[0].ip}:8200"
  token   = data.kubernetes_secret.vault_token.data["root_token"]
}