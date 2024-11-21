terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = ">= 4.0.0"
    }
  }
}

provider "keycloak" {
  client_id      = "admin-cli"
  username       = "admin"
  password       = "admin"
  url            = "https://keycloak.192.168.49.2.nip.io"
  realm          = "master"
  tls_insecure_skip_verify = true
}

# Create a new realm named "kubernetes"
resource "keycloak_realm" "kubernetes" {
  realm   = "kubernetes"
  enabled = true
}

# Create a client named "k8s"
resource "keycloak_openid_client" "k8s" {
  realm_id                     = keycloak_realm.kubernetes.id
  client_id                    = "k8s"
  name                         = "k8s"
  description                  = "Client for Kubernetes"
  enabled                      = true
  access_type                  = "PUBLIC"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "/*"
  ]
}

# Create a group named "nfs"
resource "keycloak_group" "nfs" {
  realm_id = keycloak_realm.kubernetes.id
  name     = "nfs"
}

# Create user "luca"
resource "keycloak_user" "luca" {
  realm_id = keycloak_realm.kubernetes.id
  username = "luca"
  enabled  = true

  email      = "luca@example.com"
  first_name = "Luca"
  last_name  = "KC"
  email_verified = true

  initial_password {
    value      = "123"
    temporary  = false
  }
}

resource "keycloak_user" "juan" {
  realm_id = keycloak_realm.kubernetes.id
  username = "juan"
  enabled  = true

  email      = "juan@example.com"
  first_name = "Juan"
  last_name  = "KC"
  email_verified = true

  initial_password {
    value      = "123"
    temporary  = false
  }
}

resource "keycloak_user" "alejandro" {
  realm_id = keycloak_realm.kubernetes.id
  username = "alejandro"
  enabled  = true

  email      = "alejandro@example.com"
  first_name = "Alejandro"
  last_name  = "KC"
  email_verified = true

  initial_password {
    value      = "123"
    temporary  = false
  }
}

resource "keycloak_group_memberships" "group_members" {
  realm_id  = keycloak_realm.kubernetes.id
  group_id  = keycloak_group.nfs.id
  members = [
    keycloak_user.luca.username,
    keycloak_user.juan.username,
    keycloak_user.alejandro.username
  ]
}

resource "keycloak_openid_client_scope" "groups_client_scope" {
  realm_id               = keycloak_realm.kubernetes.id
  name                   = "groups"
  include_in_token_scope = false
  description            = "When requested, this scope will map a user's group memberships to a claim"
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id       = keycloak_realm.kubernetes.id
  client_scope_id = keycloak_openid_client_scope.groups_client_scope.id
  name           = "groups"
  claim_name     = "groups"
  full_path      = false
}

resource "keycloak_openid_client_scope" "name_client_scope" {
  realm_id               = keycloak_realm.kubernetes.id
  name                   = "name"
  include_in_token_scope = false
  description            = "When requested, this scope will map a username to a claim"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "user_attribute_mapper" {
  realm_id       = keycloak_realm.kubernetes.id
  client_scope_id = keycloak_openid_client_scope.name_client_scope.id
  name           = "name"
  user_attribute = "username"
  claim_name     = "name"
}

resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = keycloak_realm.kubernetes.id
  client_id = keycloak_openid_client.k8s.id

  default_scopes = [
    "email",
    "profile",
    "web-origins",
    "acr",
    "roles",
    keycloak_openid_client_scope.groups_client_scope.name,
    keycloak_openid_client_scope.name_client_scope.name
  ]
}
