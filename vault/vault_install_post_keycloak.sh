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
cat ./vault/token.txt | vault login -address="http://vault.internal.provider.test:8200" -
echo "****************************************************************************************************************"
echo " Setting up OIDC login" 
echo "****************************************************************************************************************"
vault auth enable -address="http://vault.internal.provider.test:8200" oidc
echo " " 
echo "****************************************************************************************************************"
echo " Adding keycloak client key to Vault"
echo "****************************************************************************************************************"
vault_client_id=$(grep VAULT_token install_log/keycloak_create.log | cut -d' ' -f2 | tr -d '\r' )
CA_PEM=$(< ./vault/certs/ca.crt)
vault write -address="http://vault.internal.provider.test:8200" auth/oidc/config \
oidc_discovery_url="https://keycloak.services.provider.test:8443/auth/realms/cicdtoolbox" \
oidc_client_id="Vault" \
oidc_client_secret=$vault_client_id \
oidc_discovery_ca_pem="$CA_PEM" \
default_role=reader 
echo " " 
echo "****************************************************************************************************************"
echo " Import the policy to vault"
echo "****************************************************************************************************************"
cat vault/reader.hcl | vault policy write -address="http://vault.internal.provider.test:8200" reader -
echo " " 
echo "****************************************************************************************************************"
echo " Deploy a Role for OIDC"
echo "****************************************************************************************************************"
vault write -address="http://vault.internal.provider.test:8200" auth/oidc/role/reader \
bound_audiences="vault" \
allowed_redirect_uris="https://vault.internal.provider.test:8200/oidc/oidc/callback" \
allowed_redirect_uris="https://vault.internal.provider.test:8200/ui/vault/auth/oidc/oidc/callback" \
user_claim="sub" \
policies=reader
