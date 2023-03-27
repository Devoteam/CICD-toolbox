#!/bin/bash

# shell script to be copied into /opt/jboss/keycloak/bin
cd /opt/jboss/keycloak/bin

#Create credentials
./kcadm.sh config credentials --server https://keycloak.services.provider.test:8443/auth --realm master --user $4 --password $1
echo "Credentials created"

#add realm
./kcadm.sh create realms \
    -s realm=cicdtoolbox \
    -s id=cicdtoolbox \
    -s enabled=true \
    -s displayName="Welcome to your Development Toolkit" \
    -s displayNameHtml="<b>Welcome to your Development Toolkit</b>"
echo "Realm created"

#add Hashicorp Vault client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Vault" \
    -s description="The Vault secrets store and PKI for the toolchain" \
    -s clientId=Vault \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://vault.internal.provider.test:8200 \
    -s adminUrl=https://vault.internal.provider.test:8200/ \
    -s 'redirectUris=[ "https://vault.internal.provider.test:8200/oidc/oidc/callback","https://vault.internal.provider.test:8200/ui/vault/auth/oidc/oidc/callback" ]' \
    -s 'webOrigins=[ "https://vault.internal.provider.test:8200/" ]' \
    -o --fields id >cicdtoolbox_VAULT

# output is Created new client with id, we now need to grep the ID out of it
VAULT_ID=$(cat cicdtoolbox_VAULT | grep id | cut -d'"' -f 4)
echo "Created Vault client with ID: ${VAULT_ID}" 

# Create Client secret
./kcadm.sh create clients/$VAULT_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$VAULT_ID/client-secret -r cicdtoolbox >cicdtoolbox_vault_secret
VAULT_token=$(grep value cicdtoolbox_vault_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Vault for Keycloak
echo "VAULT_token: ${VAULT_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name=vaultAdmin -s description='The admin role for the Infra Automators organization'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='infraautomator' -s description='Organization owner role in the Infraautomator organization'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-cicdtoolbox-read' -s description='A read-only role on the CICD toolbox'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-cicdtoolbox-write' -s description='A read-write role on the CICD toolbox'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-cicdtoolbox-admin' -s description='A read-write role on the CICD toolbox'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-netcicd-read' -s description='A read-only role on NetCICD'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-netcicd-write' -s description='A read-write role on NetCICD'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-netcicd-admin' -s description='A admin role on NetCICD'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-appcicd-read' -s description='A read-only role on AppCICD'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-appcicd-write' -s description='A read-write role on AppCICD'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-appcicd-admin' -s description='A admin role on AppCICD'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-templateapp-read' -s description='A read-only role on templateApp'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-templateapp-write' -s description='A read-write role on templateApp'
./kcadm.sh create clients/$VAULT_ID/roles -r cicdtoolbox -s name='vault-templateapp-admin' -s description='A admin role on templateApp'

# We need to add the vault-admin claim and vault-group claim to the token
./kcadm.sh create clients/$VAULT_ID/protocol-mappers/models \
    -r cicdtoolbox \
	-s name=group-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-usermodel-client-role-mapper \
    -s consentRequired=false \
	-s config="{\"multivalued\" : \"true\",\"userinfo.token.claim\" : \"true\",\"id.token.claim\" : \"true\",\"access.token.claim\" : \"true\",\"claim.name\" : \"vaultGroups\",\"jsonType.label\" : \"String\",\"usermodel.clientRoleMapping.clientId\" : \"Vault\"}"

echo "Created role-group mapper in the Client Scope" 

#download Vault OIDC file
./kcadm.sh get clients/$VAULT_ID/installation/providers/keycloak-oidc-keycloak-json -r cicdtoolbox > keycloak-vault.json

echo "Created keycloak-vault installation json" 

#add Gitea client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Gitea" \
    -s description="The Gitea git server in the toolchain" \
    -s clientId=Gitea \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://gitea.tooling.provider.test:3000 \
    -s adminUrl=https://gitea.tooling.provider.test:3000/ \
    -s 'redirectUris=[ "https://gitea.tooling.provider.test:3000/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "https://gitea.tooling.provider.test:3000/" ]' \
    -o --fields id >cicdtoolbox_GITEA

# output is Created new client with id, we now need to grep the ID out of it
GITEA_ID=$(cat cicdtoolbox_GITEA | grep id | cut -d'"' -f 4)
echo "Created Gitea client with ID: ${GITEA_ID}" 

# Create Client secret
./kcadm.sh create clients/$GITEA_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$GITEA_ID/client-secret -r cicdtoolbox >cicdtoolbox_gitea_secret
GITEA_token=$(grep value cicdtoolbox_gitea_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "GITEA_token: ${GITEA_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name=giteaAdmin -s description='The admin role for the Infra Automators organization'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='infraautomator' -s description='Organization owner role in the Infraautomator organization'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-cicdtoolbox-read' -s description='A read-only role on the CICD toolbox'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-cicdtoolbox-write' -s description='A read-write role on the CICD toolbox'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-cicdtoolbox-admin' -s description='A read-write role on the CICD toolbox'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-netcicd-read' -s description='A read-only role on NetCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-netcicd-write' -s description='A read-write role on NetCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-netcicd-admin' -s description='A admin role on NetCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-appcicd-read' -s description='A read-only role on AppCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-appcicd-write' -s description='A read-write role on AppCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-appcicd-admin' -s description='A admin role on AppCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-templateapp-read' -s description='A read-only role on templateApp'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-templateapp-write' -s description='A read-write role on templateApp'
./kcadm.sh create clients/$GITEA_ID/roles -r cicdtoolbox -s name='gitea-templateapp-admin' -s description='A admin role on templateApp'


# We need to add the gitea-admin claim and gitea-group claim to the token
./kcadm.sh create clients/$GITEA_ID/protocol-mappers/models \
    -r cicdtoolbox \
	-s name=group-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-usermodel-client-role-mapper \
    -s consentRequired=false \
	-s config="{\"multivalued\" : \"true\",\"userinfo.token.claim\" : \"true\",\"id.token.claim\" : \"true\",\"access.token.claim\" : \"true\",\"claim.name\" : \"giteaGroups\",\"jsonType.label\" : \"String\",\"usermodel.clientRoleMapping.clientId\" : \"Gitea\"}"

echo "Created role-group mapper in the Client Scope" 

#Add Jenkins client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Jenkins" \
    -s description="The Jenkins orchestrator in the toolchain" \
    -s clientId=Jenkins \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s serviceAccountsEnabled=true \
    -s authorizationServicesEnabled=true \
    -s rootUrl=https://jenkins.tooling.provider.test:8084 \
    -s adminUrl=https://jenkins.tooling.provider.test:8084/ \
    -s 'redirectUris=[ "https://jenkins.tooling.provider.test:8084/*" ]' \
    -s 'webOrigins=[ "https://jenkins.tooling.provider.test:8084/" ]' \
    -o --fields id >cicdtoolbox_JENKINS

# output is Created new client with id, we now need to grep the ID out of it
JENKINS_ID=$(cat cicdtoolbox_JENKINS | grep id | cut -d'"' -f 4)
echo "Created Jenkins client with ID: ${JENKINS_ID}" 

# Create Client secret
./kcadm.sh create clients/$JENKINS_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$JENKINS_ID/client-secret -r cicdtoolbox >cicdtoolbox_jenkins_secret
JENKINS_token=$(grep value cicdtoolbox_jenkins_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "JENKINS_token: ${JENKINS_token}"


# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-admin -s description='The admin role for Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-user -s description='A user in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-readonly -s description='A viewer in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-netcicd-agent -s description='The role to be used for a user that needs to create agents in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-netcicd-run -s description='The role to be used for a user that needs to run the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-netcicd-dev -s description='The role to be used for a user that needs to configure the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-appcicd-agent -s description='The role to be used for a user that needs to create agents in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-appcicd-run -s description='The role to be used for a user that needs to run the AppCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-appcicd-dev -s description='The role to be used for a user that needs to configure the AppCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-templateapp-agent -s description='The role to be used for a user that needs to create agents in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-templateapp-run -s description='The role to be used for a user that needs to run the templateapp pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-templateapp-dev -s description='The role to be used for a user that needs to configure the templateapp pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-cicdtoolbox-run -s description='The role to be used for a user that needs to run the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-cicdtoolbox-dev -s description='The role to be used for a user that needs to configure the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r cicdtoolbox -s name=jenkins-git -s description='A role for Jenkins to work with Git'

echo "Created Jenkins roles." 

# Now we need a service account for other systems to log into Jenkins
./kcadm.sh add-roles -r cicdtoolbox \
    --uusername service-account-jenkins \
    --cclientid realm-management \
    --rolename view-clients \
    --rolename view-realm \
    --rolename view-users \
    --rolename gitea-netcicd-read \
    --rolename gitea-netcicd-write \
    --rolename gitea-appcicd-read \
    --rolename gitea-appcicd-write \
    --rolename gitea-cicdtoolbox-read \
    --rolename gitea-cicdtoolbox-write &>cicdtoolbox_JENKINS_SCOPE

echo "Created Jenkins Service Account" 

# We need to add a client scope on the realm for Jenkins in order to include the audience in the access token
./kcadm.sh create -x "client-scopes" -r cicdtoolbox -s name=jenkins-audience -s protocol=openid-connect &>cicdtoolbox_JENKINS_SCOPE
JENKINS_SCOPE_ID=$(cat cicdtoolbox_JENKINS_SCOPE | grep id | cut -d"'" -f 2)
echo "Created Client scope for Jenkins with id: ${JENKINS_SCOPE_ID}" 

# Create a mapper for the audience
./kcadm.sh create clients/$JENKINS_ID/protocol-mappers/models \
    -r cicdtoolbox \
	-s name=jenkins-audience-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-audience-mapper \
    -s consentRequired=false \
	-s config="{\"included.client.audience\" : \"Jenkins\",\"id.token.claim\" : \"false\",\"access.token.claim\" : \"true\"}"

echo "Created audience mapper in the Client Scope" 

# We need to add the scope to the token
./kcadm.sh update clients/$JENKINS_ID/default-client-scopes/${JENKINS_SCOPE_ID} -r cicdtoolbox 

echo "Included Jenkins Audience in token" 

./kcadm.sh create clients/$JENKINS_ID/protocol-mappers/models \
    -r cicdtoolbox \
	-s name=role-group-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-usermodel-client-role-mapper \
    -s consentRequired=false \
	-s config="{\"multivalued\" : \"true\",\"userinfo.token.claim\" : \"true\",\"id.token.claim\" : \"false\",\"access.token.claim\" : \"false\",\"claim.name\" : \"group-membership\",\"jsonType.label\" : \"String\",\"usermodel.clientRoleMapping.clientId\" : \"Jenkins\"}"

echo "Created role-group mapper in the Client Scope for Jenkins" 
echo "Jenkins configuration finished"
echo ""

#Add Nexus
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Nexus" \
    -s description="The Nexus repository in the toolchain" \
    -s clientId=Nexus \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s serviceAccountsEnabled=true \
    -s authorizationServicesEnabled=true \
    -s rootUrl=https://nexus.tooling.provider.test:8443 \
    -s adminUrl=https://nexus.tooling.provider.test:8443/ \
    -s 'redirectUris=[ "https://nexus.tooling.provider.test:8443/*" ]' \
    -s 'webOrigins=[ "https://nexus.tooling.provider.test:8443/" ]' \
    -o --fields id >cicdtoolbox_NEXUS

# output is Created new client with id, we now need to grep the ID out of it
NEXUS_ID=$(cat cicdtoolbox_NEXUS | grep id | cut -d'"' -f 4)
echo "Created Nexus client with ID: ${NEXUS_ID}" 

# Create Client secret
./kcadm.sh create clients/$NEXUS_ID/client-secret -r cicdtoolbox

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$NEXUS_ID/roles -r cicdtoolbox -s name=nexus-admin -s description='The admin role for Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r cicdtoolbox -s name=nexus-netcicd-agent -s description='The role to be used for a Jenkins agent to push data to Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r cicdtoolbox -s name=nexus-docker-pull -s description='The role to be used in order to pull from the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r cicdtoolbox -s name=nexus-docker-push -s description='The role to be used in order to push to the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r cicdtoolbox -s name=nexus-read -s description='The role to be used to read data on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r cicdtoolbox -s name=nexus-apk-read -s description='The role to be used for a NetCICD client to pull  APK packages data from Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r cicdtoolbox -s name=nexus-apt-ubuntu-read -s description='The role to be used for a NetCICD client to pull Ubuntu based apt packages data from Nexus'

echo "Created Nexus roles." 

# Now add the scope mappings for Nexus
RM_ID=$( ./kcadm.sh get -r cicdtoolbox clients | grep realm-management -B1 | grep id | awk -F',' '{print $(1)}' | cut -d ' ' -f5 | cut -d '"' -f2 )

./kcadm.sh create -r cicdtoolbox clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-realm\"}]"
./kcadm.sh create -r cicdtoolbox clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-users\"}]"
./kcadm.sh create -r cicdtoolbox clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-clients\"}]"
echo "Created Nexus Scope mappings" 

# Service account
./kcadm.sh add-roles -r cicdtoolbox --uusername service-account-nexus --cclientid account --rolename manage-account --rolename manage-account-links --rolename view-profile
./kcadm.sh add-roles -r cicdtoolbox --uusername service-account-nexus --cclientid Nexus --rolename uma_protection --rolename nexus-admin
./kcadm.sh add-roles -r cicdtoolbox --uusername service-account-nexus --cclientid realm-management --rolename view-clients --rolename view-realm --rolename view-users

echo "Created Nexus Service Account" 

#download Nexus OIDC file
./kcadm.sh get clients/$NEXUS_ID/installation/providers/keycloak-oidc-keycloak-json -r cicdtoolbox > keycloak-nexus.json

echo "Created keycloak-nexus installation json" 
echo "Nexus configuration finished"
echo ""

# Add Argos
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Argos" \
    -s description="The Argos notary in the toolchain" \
    -s clientId=Argos \
    -s enabled=true \
    -s publicClient=false \
    -s directAccessGrantsEnabled=true \
    -s fullScopeAllowed=false \
    -s rootUrl=http://argos.services.provider.test \
    -s adminUrl=http://argos.services.provider.test/ \
    -s 'redirectUris=[ "http://argos.services.provider.test/*" ]' \
    -s 'webOrigins=[ "http://argos.services.provider.test/" ]' \
    -o --fields id >cicdtoolbox_ARGOS

# output is Created new client with id, we now need to grep the ID out of it
ARGOS_ID=$(cat cicdtoolbox_ARGOS | grep id | cut -d'"' -f 4)
echo "Created Argos client with ID: ${ARGOS_ID}"

# Create Client secret
./kcadm.sh create clients/$ARGOS_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$ARGOS_ID/client-secret -r cicdtoolbox >cicdtoolbox_argos_secret
ARGOS_token=$(grep value cicdtoolbox_argos_secret | cut -d '"' -f4)

# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source 
echo "ARGOS_token: ${ARGOS_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$ARGOS_ID/roles -r cicdtoolbox -s name=administrator -s description='The admin role for Argos'
./kcadm.sh create clients/$ARGOS_ID/roles -r cicdtoolbox -s name=argos-user -s description='The user role for Argos'
./kcadm.sh create clients/$ARGOS_ID/roles -r cicdtoolbox -s name=argos-jenkins -s description='The jenkins user role for Argos'

#Add Build_dev node
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="build_dev" \
    -s description="First step build node for Jenkins for Development jobs" \
    -s clientId=build_dev \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://build_dev.delivery.provider.test \
    -s adminUrl=https://build_dev.delivery.provider.test:3100/ \
    -s 'redirectUris=[ "https://build_dev.delivery.provider.test:3100/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "https://build_dev.delivery.provider.test:3100/" ]' \
    -o --fields id >cicdtoolbox_build_dev

# output is Created new client with id, we now need to grep the ID out of it
BUILD_DEV_ID=$(cat cicdtoolbox_build_dev | grep id | cut -d'"' -f 4)
echo "Created cicdtoolbox_build_dev client with ID: ${BUILD_DEV_ID}" 

# Create Client secret
./kcadm.sh create clients/$BUILD_DEV_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$BUILD_DEV_ID/client-secret -r cicdtoolbox >cicdtoolbox_build_dev_secret
BUILD_DEV_token=$(grep value cicdtoolbox_build_dev_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source for Keycloak
echo "Build_dev_token: ${BUILD_DEV_token}"
echo "Build_dev configuration finished"
echo ""

#Add Build_test node
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="build_test" \
    -s description="First step build node for Jenkins for Test jobs" \
    -s clientId=build_test \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://build_test.delivery.provider.test \
    -s adminUrl=https://build_test.delivery.provider.test:3100/ \
    -s 'redirectUris=[ "https://build_test.delivery.provider.test:3100/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "https://build_test.delivery.provider.test:3100/" ]' \
    -o --fields id >cicdtoolbox_build_test

# output is Created new client with id, we now need to grep the ID out of it
BUILD_TEST_ID=$(cat cicdtoolbox_build_test | grep id | cut -d'"' -f 4)
echo "Created cicdtoolbox_build_test client with ID: ${BUILD_TEST_ID}" 

# Create Client secret
./kcadm.sh create clients/$BUILD_TEST_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$BUILD_TEST_ID/client-secret -r cicdtoolbox >cicdtoolbox_build_test_secret
BUILD_TEST_token=$(grep value cicdtoolbox_build_test_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source for Keycloak
echo "Build_test_token: ${BUILD_TEST_token}"
echo "Build_test configuration finished"
echo ""

#Add Build_acc node
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="build_acc" \
    -s description="First step build node for Jenkins for Acceptance jobs" \
    -s clientId=build_acc \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://build_acc.delivery.provider.test \
    -s adminUrl=https://build_acc.delivery.provider.test:3100/ \
    -s 'redirectUris=[ "https://build_acc.delivery.provider.test:3100/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "https://build_acc.delivery.provider.test:3100/" ]' \
    -o --fields id >cicdtoolbox_build_acc

# output is Created new client with id, we now need to grep the ID out of it
BUILD_ACC_ID=$(cat cicdtoolbox_build_acc | grep id | cut -d'"' -f 4)
echo "Created cicdtoolbox_build_acc client with ID: ${BUILD_ACC_ID}" 

# Create Client secret
./kcadm.sh create clients/$BUILD_ACC_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$BUILD_ACC_ID/client-secret -r cicdtoolbox >cicdtoolbox_build_acc_secret
BUILD_ACC_token=$(grep value cicdtoolbox_build_acc_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source for Keycloak
echo "Build_acc_token: ${BUILD_ACC_token}"

#Add Build_prod node
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="build_prod" \
    -s description="First step build node for Jenkins for Production jobs" \
    -s clientId=build_prod \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://build_prod.delivery.provider.test \
    -s adminUrl=https://build_prod.delivery.provider.test:3100/ \
    -s 'redirectUris=[ "https://build_prod.delivery.provider.test:3100/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "https://build_prod.delivery.provider.test:3100/" ]' \
    -o --fields id >cicdtoolbox_build_prod

# output is Created new client with id, we now need to grep the ID out of it
BUILD_PROD_ID=$(cat cicdtoolbox_build_prod | grep id | cut -d'"' -f 4)
echo "Created cicdtoolbox_build_prod client with ID: ${BUILD_PROD_ID}" 

# Create Client secret
./kcadm.sh create clients/$BUILD_PROD_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$BUILD_PROD_ID/client-secret -r cicdtoolbox >cicdtoolbox_build_prod_secret
BUILD_PROD_token=$(grep value cicdtoolbox_build_prod_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source for Keycloak
echo "Build_prod_token: ${BUILD_PROD_token}"
echo "Build_prod configuration finished"
echo ""

#Add Portainer client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Portainer" \
    -s description="System to manage containers in the toolchain" \
    -s clientId=Portainer \
    -s enabled=true \
    -s publicClient=true \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://portainer.monitoring.provider.test:9000 \
    -s adminUrl=http://portainer.monitoring.provider.test:9000/ \
    -s 'redirectUris=[ "http://portainer.monitoring.provider.test:9000/*" ]' \
    -s 'webOrigins=[ "http://portainer.monitoring.provider.test:9000/" ]' \
    -o --fields id >cicdtoolbox_PORTAINER

# output is Created new client with id, we now need to grep the ID out of it
PORTAINER_ID=$(cat cicdtoolbox_PORTAINER | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$PORTAINER_ID/roles -r cicdtoolbox -s name=PORTAINER-admin -s description='The admin role for Portainer'
echo "Portainer configuration finished"
echo ""

#add Loki client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Loki" \
    -s description="Grafara Loki logserver for the toolchain" \
    -s clientId=Loki \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://loki.monitoring.provider.test:3100 \
    -s adminUrl=https://loki.monitoring.provider.test:3100/ \
    -s 'redirectUris=[ "https://loki.monitoring.provider.test:3100/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "https://loki.monitoring.provider.test:3100/" ]' \
    -o --fields id >cicdtoolbox_LOKI

# output is Created new client with id, we now need to grep the ID out of it
LOKI_ID=$(cat cicdtoolbox_LOKI | grep id | cut -d'"' -f 4)
echo "Created Loki client with ID: ${LOKI_ID}" 

# Create Client secret
./kcadm.sh create clients/$LOKI_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$LOKI_ID/client-secret -r cicdtoolbox >cicdtoolbox_loki_secret
LOKI_token=$(grep value cicdtoolbox_loki_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Loki for Keycloak
echo "Loki_token: ${LOKI_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$LOKI_ID/roles -r cicdtoolbox -s name=lokiAdmin -s description='The admin role for the Infra Automators organization'
echo "Loki configuration finished"
echo ""

#add Promtail client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Promtail" \
    -s description="Grafara Promtail logserver for the toolchain" \
    -s clientId=Promtail \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=https://promtail.monitoring.provider.test \
    -s adminUrl=https://promtail.monitoring.provider.test/ \
    -s 'redirectUris=[ "https://promtail.monitoring.provider.test/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "https://promtail.monitoring.provider.test/" ]' \
    -o --fields id >cicdtoolbox_PROMTAIL

# output is Created new client with id, we now need to grep the ID out of it
PROMTAIL_ID=$(cat cicdtoolbox_PROMTAIL | grep id | cut -d'"' -f 4)
echo "Created Promtail client with ID: ${PROMTAIL_ID}" 

# Create Client secret
./kcadm.sh create clients/$PROMTAIL_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$PROMTAIL_ID/client-secret -r cicdtoolbox >cicdtoolbox_promtail_secret
PROMTAIL_token=$(grep value cicdtoolbox_promtail_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Promtail for Keycloak
echo "Promtail_token: ${PROMTAIL_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$PROMTAIL_ID/roles -r cicdtoolbox -s name=promtailAdmin -s description='The admin role for the Infra Automators organization'
echo "Promtail configuration finished"
echo ""

#add Grafana client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Grafana" \
    -s description="Grafana server for the toolchain" \
    -s clientId=Grafana \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=${authBaseUrl} \
    -s 'redirectUris=[ "http://grafana.monitoring.provider.test:3000/login/generic_oauth" ]' \
    -o --fields id >cicdtoolbox_GRAFANA

# output is Created new client with id, we now need to grep the ID out of it
GRAFANA_ID=$(cat cicdtoolbox_GRAFANA | grep id | cut -d'"' -f 4)
echo "Created Grafana client with ID: ${GRAFANA_ID}" 

# Create Client secret
./kcadm.sh create clients/$GRAFANA_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$GRAFANA_ID/client-secret -r cicdtoolbox >cicdtoolbox_grafana_secret
GRAFANA_token=$(grep value cicdtoolbox_grafana_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Grafana for Keycloak
echo "Grafana_token: ${GRAFANA_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$GRAFANA_ID/roles -r cicdtoolbox -s name=grafanaAdmin -s description='The admin role for the Infra Automators organization'

# We need to add the roles claim to the token
./kcadm.sh create clients/$GRAFANA_ID/protocol-mappers/models \
    -r cicdtoolbox \
	-s name=group-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-usermodel-client-role-mapper \
    -s consentRequired=false \
	-s config="{\"multivalued\" : \"true\",\"userinfo.token.claim\" : \"true\",\"id.token.claim\" : \"true\",\"access.token.claim\" : \"true\",\"claim.name\" : \"roles\",\"jsonType.label\" : \"String\",\"usermodel.clientRoleMapping.clientId\" : \"Grafana\"}"

echo "Created role-group mapper in the Client Scope" 
echo "Grafana configuration finished"
echo ""

#add Backstage client
./kcadm.sh create clients \
    -r cicdtoolbox \
    -s name="Backstage" \
    -s description="Backstage server for the toolchain" \
    -s clientId=Backstage \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=${authBaseUrl} \
    -s 'redirectUris=[ "http://backstage.tooling.provider.test/login/generic_oauth" ]' \
    -o --fields id >cicdtoolbox_BACKSTAGE

# output is Created new client with id, we now need to grep the ID out of it
BACKSTAGE_ID=$(cat cicdtoolbox_BACKSTAGE | grep id | cut -d'"' -f 4)
echo "Created Backstage client with ID: ${BACKSTAGE_ID}" 

# Create Client secret
./kcadm.sh create clients/$BACKSTAGE_ID/client-secret -r cicdtoolbox

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$BACKSTAGE_ID/client-secret -r cicdtoolbox >cicdtoolbox_backstage_secret
BACKSTAGE_token=$(grep value cicdtoolbox_backstage_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Backstage for Keycloak
echo "Backstage_token: ${BACKSTAGE_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$BACKSTAGE_ID/roles -r cicdtoolbox -s name=backstageAdmin -s description='The admin role for the Infra Automators organization'

# We need to add the roles claim to the token
./kcadm.sh create clients/$BACKSTAGE_ID/protocol-mappers/models \
    -r cicdtoolbox \
	-s name=group-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-usermodel-client-role-mapper \
    -s consentRequired=false \
	-s config="{\"multivalued\" : \"true\",\"userinfo.token.claim\" : \"true\",\"id.token.claim\" : \"true\",\"access.token.claim\" : \"true\",\"claim.name\" : \"roles\",\"jsonType.label\" : \"String\",\"usermodel.clientRoleMapping.clientId\" : \"Backstage\"}"

echo "Created role-group mapper in the Client Scope" 
echo "Backstage configuration finished"
echo ""

./kcadm.sh create groups -r cicdtoolbox -s name="campus_dev_lan" &>CAMPUS_DEV_LAN_DESIGNER
campus_dev_lan_designer_id=$(cat CAMPUS_DEV_LAN_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created Campus LAN Designer group with ID: ${campus_dev_lan_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_dev_lan_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_dev_lan_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_dev_lan_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Campus LAN Designers."

./kcadm.sh create groups -r cicdtoolbox -s name="campus_dev_wifi" &>CAMPUS_DEV_WIFI_DESIGNER
campus_dev_wifi_designer_id=$(cat CAMPUS_DEV_WIFI_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created Campus wifi Designer group with ID: ${campus_dev_wifi_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_dev_wifi_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_dev_wifi_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_dev_wifi_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Campus WIFI Designers."

./kcadm.sh create groups -r cicdtoolbox -s name="campus_ops_oper" &>CAMPUS_OPS_OPER
campus_ops_oper_id=$(cat CAMPUS_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created Campus Operator Group with ID: ${campus_ops_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_ops_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_ops_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_ops_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Campus Operators."

./kcadm.sh create groups -r cicdtoolbox -s name="campus_ops_spec" &>CAMPUS_OPS_SPEC
campus_ops_spec_id=$(cat CAMPUS_OPS_SPEC | grep id | cut -d"'" -f 2)
echo "Created Campus Specialists Group with ID: ${campus_ops_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_ops_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_ops_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $campus_ops_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read
     
echo "Added roles to Operations Campus Specialists."

./kcadm.sh create groups -r cicdtoolbox -s name="cicd_agents" &>cicd_AGENTS
cicd_agents_id=$(cat cicd_AGENTS | grep id | cut -d"'" -f 2)
echo "Created cicdtoolbox Agents with ID: ${cicd_agents_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $cicd_agents_id \
    --cclientid Jenkins \
    --rolename jenkins-netcicd-agent \
    --rolename jenkins-appcicd-agent \
    --rolename jenkins-templateapp-agent 


./kcadm.sh create groups -r cicdtoolbox -s name="dc_dev_compute" &>DC_DEV_COMPUTE_DESIGNER
dc_dev_compute_designer_id=$(cat DC_DEV_COMPUTE_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created Compute Designer Group with ID: ${dc_dev_compute_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_compute_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_compute_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_compute_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to DC Compute Designers."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_dev_network" &>DC_DEV_NETWORK_DESIGNER
dc_dev_network_designer_id=$(cat DC_DEV_NETWORK_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created DC Network Group with ID: ${dc_dev_network_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_network_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_network_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_network_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to DC Network Designers."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_dev_storage" &>DC_DEV_STORAGE_DESIGNER
dc_dev_storage_designer_id=$(cat DC_DEV_STORAGE_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created DC Storage Designer Group with ID: ${dc_dev_storage_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_storage_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_storage_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_dev_storage_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to DC Network Designers."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_ops_compute_oper" &>DC_OPS_COMP_OPER
dc_ops_comp_oper_id=$(cat DC_OPS_COMP_OPER | grep id | cut -d"'" -f 2)
echo "Created Compute Operator Group with ID: ${dc_ops_comp_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_comp_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_comp_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_comp_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Compute Operators."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_ops_compute_spec" &>DC_OPS_COMP_SPEC
dc_ops_comp_spec_id=$(cat DC_OPS_COMP_SPEC | grep id | cut -d"'" -f 2)
echo "Created Compute Specialists group with ID: ${dc_ops_comp_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_comp_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_comp_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_comp_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read
     
echo "Added roles to Compute Specialists."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_ops_network_oper" &>DC_OPS_NET_OPER
dc_ops_net_oper_id=$(cat DC_OPS_NET_OPER | grep id | cut -d"'" -f 2)
echo "Created DC Network Operator Group with ID: ${dc_ops_net_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_net_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_net_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_net_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to DC Network Operators."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_ops_network_spec" &>DC_OPS_NET_SPEC
dc_ops_net_spec_id=$(cat DC_OPS_NET_SPEC | grep id | cut -d"'" -f 2)
echo "Created DC Network Specialists group with ID: ${dc_ops_net_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_net_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_net_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_net_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read
     
echo "Added roles to DC Network Specialists."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_ops_storage_oper" &>DC_OPS_STOR_OPER
dc_ops_stor_oper_id=$(cat DC_OPS_STOR_OPER | grep id | cut -d"'" -f 2)
echo "Created Storage Operator Group with ID: ${dc_ops_stor_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_stor_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_stor_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_stor_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Storage Operators."

./kcadm.sh create groups -r cicdtoolbox -s name="dc_ops_storage_spec" &>DC_OPS_STOR_SPEC
dc_ops_stor_spec_id=$(cat DC_OPS_STOR_SPEC | grep id | cut -d"'" -f 2)
echo "Created Storage Specialists group with ID: ${dc_ops_stor_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_stor_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_stor_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $dc_ops_stor_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read
     
echo "Added roles to Storage Specialists."

./kcadm.sh create groups -r cicdtoolbox -s name="field_services_eng" &>FS_FSE
fs_fse_id=$(cat FS_FSE | grep id | cut -d"'" -f 2)
echo "Created Field Service Engineers group within the Field Services Department with ID: ${fs_fse_id}" 

./kcadm.sh create groups -r cicdtoolbox -s name="field_services_floor_management" &>FS_FM
fs_fm_id=$(cat FS_FM | grep id | cut -d"'" -f 2)
echo "Created Floor Management group within the Field Services Department with ID: ${fs_fm_id}" 

./kcadm.sh create groups -r cicdtoolbox -s name="git_from_jenkins" &>cicdtoolbox_J_G
j_g_id=$(cat cicdtoolbox_J_G | grep id | cut -d"'" -f 2)
echo "Created git_from_jenkins group with ID: ${j_g_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $j_g_id \
    --cclientid Jenkins \
    --rolename jenkins-git

./kcadm.sh create groups -r cicdtoolbox -s name="security_dev_design" &>SEC_DEV
sec_dev_id=$(cat SEC_DEV | grep id | cut -d"'" -f 2)
echo "Created Security Development Group with ID: ${sec_dev_id}" 

./kcadm.sh create groups -r cicdtoolbox -s name="security_ops_oper" &>SEC_OPS_OPER
sec_ops_oper_id=$(cat SEC_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created Security Operations Operator Group with ID: ${sec_ops_oper_id}" 

./kcadm.sh create groups -r cicdtoolbox -s name="security_ops_spec" &>SEC_OPS_SPEC
sec_ops_spec_id=$(cat SEC_OPS_SPEC | grep id | cut -d"'" -f 2)
echo "Created Security Operations Specialist Group with ID: ${sec_ops_spec_id}" 

./kcadm.sh create groups -r cicdtoolbox -s name="toolbox_admin" &>TOOLBOX_ADMIN
toolbox_admin_id=$(cat TOOLBOX_ADMIN | grep id | cut -d"'" -f 2)
echo "Created Toolbox Admins group with ID: ${toolbox_admin_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $toolbox_admin_id \
    --cclientid Gitea \
    --rolename infraautomator \
    --rolename giteaAdmin 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $toolbox_admin_id \
    --cclientid Jenkins \
    --rolename jenkins-admin 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $toolbox_admin_id \
    --cclientid Nexus \
    --rolename nexus-admin

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $toolbox_admin_id \
    --cclientid Argos \
    --rolename administrator

./kcadm.sh create groups -r cicdtoolbox -s name="tooling_dev_design" &>TOOL_DEV_DESIGNER
tool_dev_designer_id=$(cat TOOL_DEV_DESIGNER | grep id | cut -d"'" -f 2)

echo "Created Tooling Designer Group with ID: ${tool_dev_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_dev_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read \
    --rolename gitea-cicdtoolbox-write \
    --rolename gitea-templateapp-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_dev_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-cicdtoolbox-dev \
    --rolename jenkins-templateapp-dev

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_dev_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Tooling Designer."

./kcadm.sh create groups -r cicdtoolbox -s name="tooling_ops_oper" &>TOOL_OPS_OPER
tool_ops_oper_id=$(cat TOOL_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created Tooling Operator group within the Tooling Operations Department with ID: ${tool_ops_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_ops_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read \
    --rolename gitea-cicdtoolbox-read \
    --rolename gitea-templateapp-read \
    --rolename gitea-appcicd-read

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_ops_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-appcicd-run \
    --rolename jenkins-cicdtoolbox-run \
    --rolename jenkins-templateapp-run

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_ops_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Tooling Operator."

./kcadm.sh create groups -r cicdtoolbox -s name="tooling_ops_spec" &>TOOL_OPS_SPEC
tool_ops_spec_id=$(cat TOOL_OPS_SPEC | grep id | cut -d"'" -f 2)
echo "Created Tooling Specialist group within the Tooling Operations Department with ID: ${tool_ops_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_ops_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_ops_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run \
    --rolename jenkins-templateapp-run

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $tool_ops_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to Tooling Specialist."

./kcadm.sh create groups -r cicdtoolbox -s name="wan_dev_design" &>WAN_DEV_DESIGNER
wan_dev_designer_id=$(cat WAN_DEV_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created WAN Designer group with ID: ${wan_dev_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_dev_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_dev_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_dev_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to WAN Designer."

./kcadm.sh create groups -r cicdtoolbox -s name="wan_ops_oper" &>WAN_OPS_OPER
wan_ops_oper_id=$(cat WAN_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created WAN Operator Group with ID: ${wan_ops_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_ops_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_ops_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_ops_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read

echo "Added roles to WAN Operators."

./kcadm.sh create groups -r cicdtoolbox -s name="wan_ops_spec" &>WAN_OPS_SPEC
wan_ops_spec_id=$(cat WAN_OPS_SPEC | grep id | cut -d"'" -f 2)
echo "Created WAN Specialists Group with ID: ${wan_ops_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_ops_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_ops_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r cicdtoolbox \
    --gid $wan_ops_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read \
    --rolename nexus-apt-ubuntu-read
     
echo "Added roles to Operations WAN Specialists."

# Add LLDAP integration, needs to be last, otherwise LLDAP groups interfere with group creation in Keycloak
./kcadm.sh create components -r cicdtoolbox \
    -s name=lldap \
    -s providerId=ldap \
    -s providerType=org.keycloak.storage.UserStorageProvider \
    -s 'config.priority=["2"]' \
    -s 'config.editMode=["READ_ONLY"]' \
    -s 'config.syncRegistrations=["true"]' \
    -s 'config.vendor=["other"]' \
    -s 'config.usernameLDAPAttribute=["uid"]' \
    -s 'config.rdnLDAPAttribute=["uid"]' \
    -s 'config.uuidLDAPAttribute=["uid"]' \
    -s 'config.userObjectClasses=["person"]' \
    -s 'config.connectionUrl=["ldap://ldap.iam.provider.test:3890"]' \
    -s 'config.usersDn=["ou=people,dc=provider,dc=test"]' \
    -s 'config.searchScope=["1"]' \
    -s 'config.authType=["simple"]' \
    -s 'config.bindDn=["uid=admin,ou=people,dc=provider,dc=test"]' \
    -s 'config.bindCredential=["'$3'"]' \
    -s 'config.useTruststoreSpi=["ldapsOnly"]' \
    -s 'config.pagination=["false"]' \
    -s 'config.connectionPooling=["true"]' \
    -s 'config.useKerberosForPasswordAuthentication=["false"]' \
    -s 'config.batchSizeForSync=["1000"]' \
    -s 'config.fullSyncPeriod=["10"]' &>LLDAP_LDAP

echo "LLDAP 1 configured"

lldap_ldap_id=$(cat LLDAP_LDAP | grep id | cut -d"'" -f 2)

echo "LLDAP 2 configured"

./kcadm.sh create components -r cicdtoolbox \
    -s name=groups \
    -s providerId=group-ldap-mapper \
    -s providerType=org.keycloak.storage.ldap.mappers.LDAPStorageMapper \
    -s parentId=${lldap_ldap_id} \
    -s 'config."groups.dn"=["ou=groups,dc=provider,dc=test"]' \
    -s 'config."group.name.ldap.attribute"=["cn"]' \
    -s 'config."group.object.classes"=["groupOfUniqueNames"]' \
    -s 'config.mode=["READ_ONLY"]'

echo "LLDAP 3 configured"
#Now delete tokens and secrets
rm cicdtoolbox_*
