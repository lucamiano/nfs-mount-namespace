terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = ">= 4.0.0"
    }
  }
}

variable "keycloak_url" {
  description = "Keycloak url"
  type        = string
}

provider "keycloak" {
  client_id      = "admin-cli"
  username       = "admin"
  password       = "admin"
  url            = var.keycloak_url
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

# Create user "user1"
resource "keycloak_user" "user1" {
  realm_id = keycloak_realm.kubernetes.id
  username = "user1"
  enabled  = true

  email      = "user1@example.com"
  first_name = "user1"
  last_name  = "KC"
  email_verified = true

  initial_password {
    value      = "123"
    temporary  = false
  }
}

# Create user "user2"
resource "keycloak_user" "user2" {
  realm_id = keycloak_realm.kubernetes.id
  username = "user2"
  enabled  = true

  email      = "user2@example.com"
  first_name = "user2"
  last_name  = "KC"
  email_verified = true

  initial_password {
    value      = "123"
    temporary  = false
  }
}

# Create user "user3"
resource "keycloak_user" "user3" {
  realm_id = keycloak_realm.kubernetes.id
  username = "user3"
  enabled  = true

  email      = "user3@example.com"
  first_name = "user3"
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
    keycloak_user.user1.username,
    keycloak_user.user2.username,
    keycloak_user.user3.username
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
  ]
}
