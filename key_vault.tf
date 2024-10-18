resource "azurerm_key_vault" "credifyai" {
  name                        = "credifyai"
  location                    = data.azurerm_resource_group.credifyai.location
  resource_group_name         = data.azurerm_resource_group.credifyai.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "List",
      "Get",
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }

}

resource "azurerm_key_vault_key" "credifyai" {
  name         = "credifyai-key"
  key_vault_id = azurerm_key_vault.credifyai.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_key_vault_access_policy" "credifyai" {
  key_vault_id = azurerm_key_vault.credifyai.id

  tenant_id = azurerm_disk_encryption_set.credifyai.identity[0].tenant_id
  object_id = azurerm_disk_encryption_set.credifyai.identity[0].principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Encrypt",
    "WrapKey",
    "UnwrapKey",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
  ]
}

resource "azurerm_disk_encryption_set" "credifyai" {
  name                = "des"
  resource_group_name = data.azurerm_resource_group.credifyai.name
  location            = data.azurerm_resource_group.credifyai.location
  key_vault_key_id    = azurerm_key_vault_key.credifyai.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "credifyai" {
  scope                = azurerm_key_vault.credifyai.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.credifyai.identity[0].principal_id
}
