data "azurerm_resource_group" "credifyai" {
  name = "credifyai-resources"
}

data "azurerm_resource_group" "credifyainode" {
  name       = "credifyai-node-resources"
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}

data "azurerm_client_config" "current" {
}

resource "azurerm_kubernetes_cluster" "kubernetes" {
  name                   = "credifyai"
  location               = data.azurerm_resource_group.credifyai.location
  resource_group_name    = data.azurerm_resource_group.credifyai.name
  dns_prefix             = "credifyai"
  kubernetes_version     = "1.30.0"
  disk_encryption_set_id = azurerm_disk_encryption_set.credifyai.id
  node_resource_group    = var.node_resource_group
  default_node_pool {
    name                   = "default"
    node_count             = 1
    vm_size                = "Standard_D2_v2"
    node_public_ip_enabled = false
    vnet_subnet_id         = azurerm_subnet.nodes.id
    pod_subnet_id          = azurerm_subnet.pods.id
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  network_profile {
    network_plugin     = "azure"
    network_policy     = "cilium"
    network_data_plane = "cilium"
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
  }
  identity {
    type = "SystemAssigned"
  }

  tags = {
    project = "credifyai"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "internal" {
  name                    = "internal"
  kubernetes_cluster_id   = azurerm_kubernetes_cluster.kubernetes.id
  vm_size                 = "Standard_DS2_v2"
  node_count              = 1
  auto_scaling_enabled    = true
  host_encryption_enabled = true
  max_count               = 10
  min_count               = 1
  pod_subnet_id           = azurerm_subnet.pods.id
  node_public_ip_enabled  = false
  fips_enabled            = false
  node_taints             = []
  vnet_subnet_id          = azurerm_subnet.nodes.id
  zones                   = []
  tags = {
    project = "credifyai"
  }
}

resource "null_resource" "kube_config" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ~/.kube/config
      az aks get-credentials --resource-group ${var.resource_group} --name ${var.cluster_name}
    EOT
  }
  depends_on = [azurerm_kubernetes_cluster.kubernetes]
}