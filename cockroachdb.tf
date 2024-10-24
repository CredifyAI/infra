resource "kubernetes_service_account" "crdb_sa" {
  metadata {
    name      = "credifyai-crdb"
    namespace = "crdb"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name"      = "cockroachdb"
      "meta.helm.sh/release-namespace" = "crdb"
    }
  }
  depends_on = [kubernetes_namespace.crdb]
}

# resource "helm_release" "crdb_init" {
#   name       = "cockroachdb"
#   repository = "https://credifyai.github.io/helm-cockroachdb"
#   chart      = "cockroachdb"
#   version    = "13.0.19" 
#   namespace = kubernetes_namespace.crdb.metadata[0].name
#   values = [<<-EOF
#     statefulset:
#       replicas: 1  
#     init:
#       provisioning:
#         users: 
#         - name: credifyai
#           password: admin
#   EOF
#   ]
#   depends_on = [ kubernetes_service_account.crdb_sa ]
# } 

# resource "time_sleep" "thirty" {

#   create_duration = "30s"
# }

# resource "null_resource" "crdb_cleanup" {
#  provisioner "local-exec" {
#     command = <<-EOF
#       helm uninstall -n crdb cockroachdb
#       sleep 120
#     EOF
#   }
#   depends_on = [ vault_database_secret_backend_connection.crdb ]
# }

resource "helm_release" "crdb_final" {
  name       = "cockroachdb"
  repository = "https://credifyai.github.io/helm-cockroachdb"
  chart      = "cockroachdb"
  version    = "13.0.17"
  namespace  = kubernetes_namespace.crdb.metadata[0].name
  values = [<<-EOF
    init:
      provisioning:
        users: 
        - name: credifyai
          password: admin
  EOF
  ]
  depends_on = [kubernetes_service_account.crdb_sa]
}

resource "null_resource" "crdb-init" {
  provisioner "local-exec" {
    command = <<EOT
        kubectl exec -n crdb cockroachdb-client-secure -- cockroach sql --host=cockroachdb-public.crdb --certs-dir=cockroach-certs --execute="GRANT admin TO credifyai";
    EOT
  }
  depends_on = [helm_release.crdb_final]
}

resource "null_resource" "crdb-rotate" {
  provisioner "local-exec" {
    command = <<EOT
        kubectl exec -n vault vault-server-0 -- vault write -force crdb/rotate-root/crdb
    EOT
  }
  depends_on = [vault_database_secret_backend_role.crdb_role]
}