resource "null_resource" "crdb_install" {
  provisioner "local-exec" {
    command = <<EOT
    latest_release=$(curl -L -s "https://api.github.com/repos/CredifyAI/helm-cockroachdb/releases/latest" | jq -r '.assets[0].browser_download_url')
    curl -L -s -H 'Accept:application/octet-stream' "$latest_release" -o crdb_asset.tgz
    helm install cockroachdb crdb_asset.tgz -n crdb
    rm -rf crdb_asset.tgz
    EOT
  }
  depends_on = [kubernetes_namespace.crdb, vault_kubernetes_auth_backend_role.crdb_role]
}