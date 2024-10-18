resource "kubernetes_namespace" "frontend" {
  metadata {
    labels = {
      namespace = "frontend"
    }

    name = "frontend"
  }
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}

resource "kubernetes_namespace" "crdb" {
  metadata {
    labels = {
      namespace       = "crdb"
      istio-injection = "disabled"
    }

    name = "crdb"
  }
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}

resource "kubernetes_namespace" "istio" {
  metadata {
    labels = {
      namespace       = "istio"
      istio-injection = "enabled"
    }

    name = "istio-system"
  }
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}

resource "kubernetes_namespace" "istio_gw" {
  metadata {
    labels = {
      namespace       = "istio-ingress"
      istio-injection = "enabled"
    }

    name = "istio-ingress"
  }
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    labels = {
      namespace       = "monitoring"
      istio-injection = "disabled"
    }

    name = "monitoring"
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    labels = {
      namespace       = "logging"
      istio-injection = "disabled"
    }

    name = "logging"
  }
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    labels = {
      namespace       = "argocd"
      istio-injection = "disabled"
    }

    name = "argocd"
  }
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}