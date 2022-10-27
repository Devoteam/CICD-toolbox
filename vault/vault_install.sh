
#!/bin/bash

function create_intermediate() {
    echo "****************************************************************************************************************"
    echo " Preparing ${1} intermediate CA in Vault" 
    echo "****************************************************************************************************************"
    vault secrets enable -path=pki_intermediate_$1 pki
    vault secrets tune -max-lease-ttl=43800h pki_intermediate_$1
    vault write -format=json pki_intermediate_$1/intermediate/generate/internal common_name="${1}.provider.test Intermediate Authority" | jq -r '.data.csr' > pki_intermediate_$1.csr
    vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate_$1.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > pki_intermediate_$1.crt
    vault write pki_intermediate_$1/intermediate/set-signed certificate=@pki_intermediate_$1.crt
    echo "****************************************************************************************************************"
    echo " Define role to permit issueing leaf certificates" 
    echo "****************************************************************************************************************"
    vault write pki_int/roles/$1.provider.test allowed_domains="${1}.provider.test" allow_subdomains=true max_ttl="8760h"
    echo " " 
}

function create_leaf () {
    vault write -format=json pki_int/issue/$1 common_name="${2}.${1}.provider.tooling.test" ttl="8760h" > $2.$1.provider.test.json
    cat $2.$1.provider.test.json | jq -r '.data.private_key' > $2.$1.provider.test.pem
    cat $2.$1.provider.test.json | jq -r '.data.certificate' > $2.$1.provider.test.crt
    cat $2.$1.provider.test.json | jq -r '.data.ca_chain[]' >> $2.$1.provider.test.crt
    rm $2.$1.provider.test.json
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
cat key.txt | vault login -address="http://vault.internal.provider.test:8200" -
echo "****************************************************************************************************************"
echo " Preparing Root CA in Vault" 
echo "****************************************************************************************************************"
vault write -field=certificate pki/root/generate/internal common_name="provider.test" ttl=87600h > ca.crt
vault write pki/config/urls issuing_certificates="http://vault.internal.provider.test:8200/v1/pki/ca" crl_distribution_points="http://vault.internal.provider.test:8200/v1/pki/crl"
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
create leaf loki monitoring
create leaf promtail monitoring
create leaf grafana monitoring
create_leaf restportal services 
create_leaf argos services 
create_leaf keycloak services 
create_leaf gitea tooling 
create_leaf argos-service tooling 
create_leaf jenkins tooling 
create_leaf nexus tooling 
create_leaf netbox tooling 

