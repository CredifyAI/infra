resource "kubernetes_storage_class" "azure" {
  metadata {
    name = "credify-managed-disks"
  }

  storage_provisioner = "kubernetes.io/azure-disk"

  parameters = {
    storageaccounttype = "Standard_LRS"
    kind               = "Managed"
    resourceGroup      = var.resource_group
  }

  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
}

resource "null_resource" "crdb_install" {
  provisioner "local-exec" {
    command = <<EOT
    rm -rf crdb_asset.tgz
    latest_release=$(curl -L -s "https://api.github.com/repos/CredifyAI/helm-cockroachdb/releases/latest" | jq -r '.assets[0].browser_download_url')
    curl -L -s -H 'Accept:application/octet-stream' "$latest_release" -o crdb_asset.tgz
    helm install cockroachdb crdb_asset.tgz -n crdb
    EOT
  }
  depends_on = [kubernetes_namespace.crdb, kubernetes_storage_class.azure]
}