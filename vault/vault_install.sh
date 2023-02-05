
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

function create_intermediate() {
    echo "****************************************************************************************************************"
    echo " Preparing ${1} intermediate CA in Vault" 
    echo "****************************************************************************************************************"
    vault secrets enable -address="http://vault.internal.provider.test:8200" -path=pki_intermediate_$1 pki
    vault secrets tune -address="http://vault.internal.provider.test:8200" -max-lease-ttl=43800h pki_intermediate_$1
    vault write -address="http://vault.internal.provider.test:8200" -format=json pki_intermediate_$1/intermediate/generate/internal common_name="${1}.provider.test Intermediate Authority" | jq -r '.data.csr' > ./vault/certs/pki_intermediate_$1.csr
    vault write -address="http://vault.internal.provider.test:8200" -format=json pki/root/sign-intermediate csr=@vault/certs/pki_intermediate_$1.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > ./vault/certs/pki_intermediate_$1.crt
    vault write -address="http://vault.internal.provider.test:8200" pki_intermediate_$1/intermediate/set-signed certificate=@vault/certs/pki_intermediate_$1.crt
    echo "****************************************************************************************************************"
    echo " Define role to permit issueing leaf certificates" 
    echo "****************************************************************************************************************"
    vault write -address="http://vault.internal.provider.test:8200" pki_intermediate_$1/roles/$1.provider.test allowed_domains="${1}.provider.test" allow_subdomains=true max_ttl="8760h"
    echo " " 
}

function create_leaf() {
    vault write -address="http://vault.internal.provider.test:8200" -format=json pki_intermediate_$2/issue/$2.provider.test common_name="${1}.${2}.provider.test" ttl="8760h" > ./vault/certs/$1.$2.provider.test.json
    cat ./vault/certs/$1.$2.provider.test.json | jq -r '.data.private_key' > ./vault/certs/$1.$2.provider.test.pem
    cat ./vault/certs/$1.$2.provider.test.json | jq -r '.data.certificate' > ./vault/certs/$1.$2.provider.test.crt
    cat ./vault/certs/$1.$2.provider.test.json | jq -r '.data.ca_chain[]' >> ./vault/certs/$1.$2.provider.test.crt
    rm ./vault/certs/$1.$2.provider.test.json
}

function create_database() {
    vault write -address="http://vault.internal.provider.test:8200" database/config/$1 \
    plugin_name="postgresql-database-plugin" \
    allowed_roles=$1 \
    connection_url="postgresql://{{username}}:{{password}}@cicdtoolbox-db.internal.provider.test:5432/${1}" \
    username=$1 \
    password=$1

    vault write -address="http://vault.internal.provider.test:8200" database/roles/$1 \
    db_name=$1 \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

    vault write -force  -address="http://vault.internal.provider.test:8200" database/rotate-root/$1
}

echo "****************************************************************************************************************"
echo " Creating Vault with a Consul backend" 
echo "****************************************************************************************************************"
docker-compose pull 
docker-compose up -d --build --remove-orphans consul.internal.provider.test
docker-compose up -d --build --remove-orphans vault.internal.provider.test
echo "****************************************************************************************************************"
echo " Wait until vault is running (~5 sec.)"
echo "****************************************************************************************************************"
let t=0
until $(curl --output /dev/null --insecure --silent --head --fail http://vault.internal.provider.test:8200); do
    spin
done
endspin
echo " "
echo "****************************************************************************************************************"
echo " Initialize Vault, unseal and create secrets engines."
echo "****************************************************************************************************************"
robot -o ./install_log/vault.xml -l ./install_log/vault_log.html -r ./install_log/vault_report.html ./vault/vault-setup.robot
echo "****************************************************************************************************************"
echo " " 
echo "****************************************************************************************************************"
echo " We now have a Hashicorp Vault running with Consul. " 
echo "****************************************************************************************************************"
echo " " 
echo "****************************************************************************************************************"
echo " CLI Login to Vault" 
echo "****************************************************************************************************************"
cat ./vault/token.txt | vault login -address="http://vault.internal.provider.test:8200" -
echo "****************************************************************************************************************"
echo " Preparing Root CA in Vault" 
echo "****************************************************************************************************************"
vault secrets tune -address="http://vault.internal.provider.test:8200" -max-lease-ttl=87600h pki
vault write -address="http://vault.internal.provider.test:8200" -field=certificate pki/root/generate/internal common_name="provider.test" ttl=87600h > ./vault/certs/ca.crt
vault write -address="http://vault.internal.provider.test:8200" pki/config/urls issuing_certificates="http://vault.internal.provider.test:8200/v1/pki/ca" crl_distribution_points="http://vault.internal.provider.test:8200/v1/pki/crl"
echo " " 
echo "****************************************************************************************************************"
echo " Creating intermediates" 
echo "****************************************************************************************************************"
echo " " 
create_intermediate access
create_intermediate delivery
create_intermediate iam
create_intermediate internal
create_intermediate monitoring
create_intermediate tooling
create_intermediate services
echo "****************************************************************************************************************"
echo " Intermediates defined" 
echo "****************************************************************************************************************"
echo " " 
echo "****************************************************************************************************************"
echo " Creating leaf certificates" 
echo "****************************************************************************************************************"
echo " " 
create_leaf build-dev delivery 
create_leaf build-test delivery 
create_leaf build-acc delivery 
create_leaf build-prod delivery 
create_leaf ldap iam 
create_leaf cicdtoolbox-db internal 
create_leaf mongodb internal
create_leaf redis internal 
create_leaf loki monitoring
create_leaf promtail monitoring
create_leaf grafana monitoring
create_leaf restportal services 
create_leaf argos services 
create_leaf keycloak services 
create_leaf gitea tooling 
create_leaf argos-service tooling 
create_leaf jenkins tooling 
create_leaf nexus tooling 
create_leaf netbox tooling 
echo " " 
echo "****************************************************************************************************************"
echo " Preparing PostgreSQL database use" 
echo "****************************************************************************************************************"
echo " " 
vault secrets enable -address="http://vault.internal.provider.test:8200" database
#create_database myreference