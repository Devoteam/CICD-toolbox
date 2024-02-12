#!/bin/bash

sp="/-\|"
sc=0
spin() {
   printf -- "${sp:sc++:1}  ( ${t} sec.) \r"
   ((sc==${#sp})) && sc=0
   sleep 1
   let t+=1
}

endspin() {
   printf "\r%s\n" "$@"
}
echo "****************************************************************************************************************"
echo " CLI Login to Vault" 
echo "****************************************************************************************************************"
vault login -address="https://vault.internal.provider.test:8200" $(cat vault/token.txt)
echo "****************************************************************************************************************"
echo " Setting up OIDC login" 
echo "****************************************************************************************************************"
echo " " 
echo "****************************************************************************************************************"
echo " Loading OIDC Vault-admin policy" 
echo "****************************************************************************************************************"
echo " " 
# vault policy write -address="https://vault.internal.provider.test:8200" vault_admin vault/vault-admin_policy.hcl
# vault write -address="https://vault.internal.provider.test:8200" identity/group name="vault-admin" type="external"
# vault write -address="https://vault.internal.provider.test:8200" identity/group/name/vault-admin policies=vault_admin 
# vault write -address="https://vault.internal.provider.test:8200" identity/group-alias name="vault-admin" mount_accessor=<jwt_auth_backend_accessor> canonical_id=<vault_identity_group_id>
export VAULT_ADDR=https://vault.internal.provider.test:8200
export VAULT_TOKEN=$(cat vault/token.txt)
export TF_VAR_client_secret=$(grep VAULT_token install_log/keycloak_create.log | cut -d' ' -f2 | tr -d '\r' )
export TF_VAR_client_id="Vault"
terraform -chdir=terraform/vault init -input=false
terraform -chdir=terraform/vault apply --auto-approve
# vault auth enable -address="https://vault.internal.provider.test:8200" oidc
# echo " " 
# echo "****************************************************************************************************************"
# echo " Adding keycloak client key to Vault"
# echo "****************************************************************************************************************"
# vault_client_id=$(grep VAULT_token install_log/keycloak_create.log | cut -d' ' -f2 | tr -d '\r' )
# CA_PEM=$(< ./vault/certs/ca.crt)
# vault write -address="https://vault.internal.provider.test:8200" auth/oidc/config \
# oidc_discovery_url="https://keycloak.services.provider.test:8443/realms/cicdtoolbox" \
# oidc_client_id="Vault" \
# oidc_client_secret=$vault_client_id \
# oidc_discovery_ca_pem="$CA_PEM" \
# default_role=reader \
# boud_issuer="https://keycloak.services.provider.test:8443/realms/cicdtoolbox"
# echo " " 
# echo "****************************************************************************************************************"
# echo " Import the policy to vault"
# echo "****************************************************************************************************************"
# vault policy write -address="https://vault.internal.provider.test:8200" reader vault/reader.hcl
# echo " " 
# echo "****************************************************************************************************************"
# echo " Deploy a Role for OIDC"
# echo "****************************************************************************************************************"
# vault write -address="https://vault.internal.provider.test:8200" auth/oidc/role/reader \
# bound_audiences="vault" \
# allowed_redirect_uris="https://vault.internal.provider.test:8200/oidc/oidc/callback" \
# allowed_redirect_uris="https://vault.internal.provider.test:8200/ui/vault/auth/oidc/oidc/callback" \
# user_claim="sub" \
# policies=reader