resource "kubernetes_storage_class" "azure" {
  metadata {
    name = "credify-managed-disks"
  }

  storage_provisioner = "kubernetes.io/azure-disk"

  parameters = {
    storageaccounttype = "Standard_LRS"
    kind               = "Managed"
    resourceGroup      = var.node_resource_group
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
}