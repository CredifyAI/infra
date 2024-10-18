resource "null_resource" "crdb_install" {
  provisioner "local-exec" {
    command = <<EOT
    rm -rf crdb_asset.tgz
    latest_release=$(curl -L -s "https://api.github.com/repos/CredifyAI/helm-cockroachdb/releases/latest" | jq -r '.assets[0].browser_download_url')
    curl -L -s -H 'Accept:application/octet-stream' "$latest_release" -o crdb_asset.tgz
    tar -zxvf crdb_asset.tgz
    helm install cockroachdb crdb_asset-*.tgz -n crdb
    EOT
  }
  depends_on = [kubernetes_namespace.crdb]
}