#!/bin/bash
# first insert FreeeIPA CA cert into Keycloak keystore
echo "Adding CA certificate to Java truststore..."
chmod 777 /opt/jboss/keycloak/standalone/configuration/keystores 
cd /opt/jboss/keycloak/standalone/configuration/keystores 
keytool -keystore truststore -storepass password -noprompt -trustcacerts -importcert -alias freeipa-ca -file freeipa-ca.crt
chmod 444 /opt/jboss/keycloak/standalone/configuration/keystores 

# shell script to be copied into /opt/jboss/keycloak/bin
cd /opt/jboss/keycloak/bin

#Create credentials
./kcadm.sh config credentials --server http://keycloak.tooling.test:8080/auth --realm master --user admin --password Pa55w0rd

#add realm
./kcadm.sh create realms \
    -s realm=netcicd \
    -s id=netcicd \
    -s enabled=true \
    -s displayName="Welcome to the Infrastructure Development Toolkit" \
    -s displayNameHtml="<b>Welcome to the Infrastructure Development Toolkit</b>"

#add clients
./kcadm.sh create clients \
    -r netcicd \
    -s name="Gitea" \
    -s description="The Gitea git server in the toolchain" \
    -s clientId=Gitea \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=true \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://gitea.tooling.test:3000 \
    -s adminUrl=http://gitea.tooling.test:3000/ \
    -s 'redirectUris=[ "http://gitea.tooling.test:3000/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "http://gitea.tooling.test:3000/" ]' \
    -o --fields id >NetCICD_GITEA

# output is Created new client with id, we now need to grep the ID out of it
GITEA_ID=$(cat NetCICD_GITEA | grep id | cut -d'"' -f 4)
echo "Created Gitea client with ID: ${GITEA_ID}" 

# Create Client secret
./kcadm.sh create clients/$GITEA_ID/client-secret -r netcicd

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$GITEA_ID/client-secret -r netcicd >NetCICD_gitea_secret
GITEA_token=$(grep value NetCICD_gitea_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "GITEA_token: ${GITEA_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-infraautomators-admin -s description='The admin role for the Infra Automators organization'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-read -s description='A read-only role on NetCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-write -s description='A read-write role on NetCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-admin -s description='A admin role on NetCICD'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-cicdtoolbox-read -s description='A read-only role on the CICD toolbox'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-cicdtoolbox-write -s description='A read-write role on the CICD toolbox'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-cicdtoolbox-admin -s description='A read-write role on the CICD toolbox'

./kcadm.sh create clients \
    -r netcicd \
    -s name="Jenkins" \
    -s description="The Jenkins orchestrator in the toolchain" \
    -s clientId=Jenkins \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s serviceAccountsEnabled=true \
    -s authorizationServicesEnabled=true \
    -s rootUrl=http://jenkins.tooling.test:8084 \
    -s adminUrl=http://jenkins.tooling.test:8084/ \
    -s 'redirectUris=[ "http://jenkins.tooling.test:8084/*" ]' \
    -s 'webOrigins=[ "http://jenkins.tooling.test:8084/" ]' \
    -o --fields id >NetCICD_JENKINS

# output is Created new client with id, we now need to grep the ID out of it
JENKINS_ID=$(cat NetCICD_JENKINS | grep id | cut -d'"' -f 4)
echo "Created Jenkins client with ID: ${JENKINS_ID}" 

# Create Client secret
./kcadm.sh create clients/$JENKINS_ID/client-secret -r netcicd

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$JENKINS_ID/client-secret -r netcicd >NetCICD_jenkins_secret
JENKINS_token=$(grep value NetCICD_jenkins_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "JENKINS_token: ${JENKINS_token}"


# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-admin -s description='The admin role for Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-user -s description='A user in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-readonly -s description='A viewer in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-agent -s description='The role to be used for a user that needs to create agents in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-run -s description='The role to be used for a user that needs to run the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-dev -s description='The role to be used for a user that needs to configure the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-cicdtoolbox-run -s description='The role to be used for a user that needs to run the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-cicdtoolbox-dev -s description='The role to be used for a user that needs to configure the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-git -s description='A role for Jenkins to work with Git'

echo "Created Jenkins roles." 

# Now we need a service account for other systems to log into Jenkins
./kcadm.sh add-roles -r netcicd --uusername service-account-jenkins --cclientid realm-management --rolename view-clients --rolename view-realm --rolename view-users

echo "Created Jenkins Service Account" 

# We need to add a client scope on the realm for Jenkins in order to include the audience in the access token
./kcadm.sh create -x "client-scopes" -r netcicd -s name=jenkins-audience -s protocol=openid-connect &>NetCICD_JENKINS_SCOPE
JENKINS_SCOPE_ID=$(cat NetCICD_JENKINS_SCOPE | grep id | cut -d"'" -f 2)
echo "Created Client scope for Jenkins with id: ${JENKINS_SCOPE_ID}" 

# Create a mapper for the audience
./kcadm.sh create clients/$JENKINS_ID/protocol-mappers/models \
    -r netcicd \
	-s name=jenkins-audience-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-audience-mapper \
    -s consentRequired=false \
	-s config="{\"included.client.audience\" : \"Jenkins\",\"id.token.claim\" : \"false\",\"access.token.claim\" : \"true\"}"

echo "Created audience mapper in the Client Scope" 

# We need to add the scope to the token
./kcadm.sh update clients/$JENKINS_ID -r netcicd --body "{\"defaultClientScopes\": [\"jenkins-audience\"]}"

echo "Included Jenkins Audience in token" 

./kcadm.sh create clients/$JENKINS_ID/protocol-mappers/models \
    -r netcicd \
	-s name=role-group-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-usermodel-client-role-mapper \
    -s consentRequired=false \
	-s config="{\"multivalued\" : \"true\",\"userinfo.token.claim\" : \"true\",\"id.token.claim\" : \"false\",\"access.token.claim\" : \"false\",\"claim.name\" : \"group-membership\",\"jsonType.label\" : \"String\",\"usermodel.clientRoleMapping.clientId\" : \"Jenkins\"}"

echo "Created role-group mapper in the Client Scope" 
echo " "

#download Jenkins OIDC file
#./kcadm.sh get clients/$JENKINS_ID/installation/providers/keycloak-oidc-keycloak-json -r netcicd > keycloak-jenkins.json

#echo "Created keycloak-jenkins installation json" 
#

./kcadm.sh create clients \
    -r netcicd \
    -s name="Nexus" \
    -s description="The Nexus repository in the toolchain" \
    -s clientId=Nexus \
    -s enabled=true \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s serviceAccountsEnabled=true \
    -s authorizationServicesEnabled=true \
    -s rootUrl=http://nexus.tooling.test:8081 \
    -s adminUrl=http://nexus.tooling.test:8081/ \
    -s 'redirectUris=[ "http://nexus.tooling.test:8081/*" ]' \
    -s 'webOrigins=[ "http://nexus.tooling.test:8081/" ]' \
    -o --fields id >NetCICD_NEXUS

# output is Created new client with id, we now need to grep the ID out of it
NEXUS_ID=$(cat NetCICD_NEXUS | grep id | cut -d'"' -f 4)
echo "Created Nexus client with ID: ${NEXUS_ID}" 
echo " "

# Create Client secret
./kcadm.sh create clients/$NEXUS_ID/client-secret -r netcicd

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-admin -s description='The admin role for Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-netcicd-agent -s description='The role to be used for a Jenkins agent to push data to Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-docker-pull -s description='The role to be used in order to pull from the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-docker-push -s description='The role to be used in order to push to the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-read -s description='The role to be used for a Jenkins agent to push data to Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-apk-read -s description='The role to be used for a NetCICD client to pull  APK packages data from Nexus'

echo "Created Nexus roles." 

# Now add the scope mappings for Nexus
RM_ID=$( ./kcadm.sh get -r netcicd clients | grep realm-management -B1 | grep id | awk -F',' '{print $(1)}' | cut -d ' ' -f5 | cut -d '"' -f2 )

./kcadm.sh create -r netcicd clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-realm\"}]"
./kcadm.sh create -r netcicd clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-users\"}]"
./kcadm.sh create -r netcicd clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-clients\"}]"

# Service account
./kcadm.sh add-roles -r netcicd --uusername service-account-nexus --cclientid account --rolename manage-account --rolename manage-account-links --rolename view-profile
./kcadm.sh add-roles -r netcicd --uusername service-account-nexus --cclientid Nexus --rolename uma_protection
./kcadm.sh add-roles -r netcicd --uusername service-account-nexus --cclientid realm-management --rolename view-clients --rolename view-realm --rolename view-users

echo "Created Nexus Service Account" 

#download Nexus OIDC file
./kcadm.sh get clients/$NEXUS_ID/installation/providers/keycloak-oidc-keycloak-json -r netcicd > keycloak-nexus.json

echo "Created keycloak-nexus installation json" 

./kcadm.sh create clients \
    -r netcicd \
    -s name="Portainer" \
    -s description="System to manage containers in the toolchain" \
    -s clientId=Portainer \
    -s enabled=true \
    -s publicClient=true \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://portainer.tooling.test:9000 \
    -s adminUrl=http://portainer.tooling.test:9000/ \
    -s 'redirectUris=[ "http://portainer.tooling.test:9000/*" ]' \
    -s 'webOrigins=[ "http://portainer.tooling.test:9000/" ]' \
    -o --fields id >NetCICD_PORTAINER

# output is Created new client with id, we now need to grep the ID out of it
PORTAINER_ID=$(cat NetCICD_PORTAINER | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$PORTAINER_ID/roles -r netcicd -s name=PORTAINER-admin -s description='The admin role for FreeRADIUS'

#add groups - we start at the system level, which implements the groups related to service accounts
./kcadm.sh create groups -r netcicd -s name="System" &>NetCICD_SYSTEM
system_id=$(cat NetCICD_SYSTEM | grep id | cut -d"'" -f 2)
echo "Created System Group with ID: ${system_id}" 

./kcadm.sh create groups/$system_id/children -r netcicd -s name="jenkins-git" &>NetCICD_J_G
j_g_id=$(cat NetCICD_J_G | grep id | cut -d"'" -f 2)
echo "Created jenkins-git group with ID: ${j_g_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $j_g_id \
    --cclientid Jenkins \
    --rolename jenkins-git

#add groups - we start at the ICT infra level, which implements the capacity layer of the MyREFerence model
./kcadm.sh create groups -r netcicd -s name="Identity and Access Management" &>DOM_IAM
dom_iam_id=$(cat DOM_IAM | grep id | cut -d"'" -f 2)
echo "Created Identity and Access Management Domain with ID: ${dom_iam_id}" 

./kcadm.sh create groups/$dom_iam_id/children -r netcicd -s name="1 - IAM Operations" &>IAM_OPS
iam_ops_id=$(cat IAM_OPS | grep id | cut -d"'" -f 2)
echo "Created IAM Operations Group with ID: ${iam_ops_id}" 

./kcadm.sh create groups/$iam_ops_id/children -r netcicd -s name="IAM Operators" &>IAM_OPS_OPER
iam_ops_oper_id=$(cat IAM_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created IAM Operator Group within IAM Operations Group with ID: ${iam_ops_oper_id}" 

./kcadm.sh create groups/$iam_ops_id/children -r netcicd -s name="IAM Specialists" &>IAM_OPS_SPEC
iam_ops_spec_id=$(cat IAM_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created IAM Operator Group within IAM Operations Group with ID: ${iam_ops_oper_id}" 

./kcadm.sh create groups/$dom_iam_id/children -r netcicd -s name="2 - IAM Development" &>IAM_DEV
iam_dev_id=$(cat IAM_DEV | grep id | cut -d"'" -f 2)
echo "Created IAM Development Group with ID: ${iam_dev_id}" 

./kcadm.sh create groups -r netcicd -s name="Office" &>DOM_OFFICE
dom_office_id=$(cat DOM_OFFICE | grep id | cut -d"'" -f 2)
echo "Created Office Domain with ID: ${dom_office_id}" 

./kcadm.sh create groups/$dom_office_id/children -r netcicd -s name="1 - Office Operations" &>OFFICE_OPS
office_ops_id=$(cat OFFICE_OPS | grep id | cut -d"'" -f 2)
echo "Created Office Operations Group with ID: ${office_ops_id}" 

./kcadm.sh create groups/$office_ops_id/children -r netcicd -s name="Office Operators" &>OFFICE_OPS_OPER
office_ops_oper_id=$(cat OFFICE_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created Office Operator Group within Office Operations Group with ID: ${office_ops_oper_id}" 

./kcadm.sh create groups/$office_ops_id/children -r netcicd -s name="Office Specialists" &>OFFICE_OPS_SPEC
office_ops_spec_id=$(cat OFFICE_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created Office Operator Group within Office Operations Group with ID: ${office_ops_oper_id}" 

./kcadm.sh create groups/$dom_office_id/children -r netcicd -s name="2 - Office Development" &>OFFICE_DEV
office_dev_id=$(cat OFFICE_DEV | grep id | cut -d"'" -f 2)
echo "Created Office Development Group with ID: ${office_dev_id}" 

./kcadm.sh create groups -r netcicd -s name="Campus" &>DOM_CAMPUS
dom_campus_id=$(cat DOM_CAMPUS | grep id | cut -d"'" -f 2)
echo "Created Campus Domain with ID: ${dom_campus_id}" 

./kcadm.sh create groups/$dom_campus_id/children -r netcicd -s name="1 - Campus Operations" &>CAMPUS_OPS
campus_ops_id=$(cat CAMPUS_OPS | grep id | cut -d"'" -f 2)
echo "Created Campus Operations Group with ID: ${campus_ops_id}" 

./kcadm.sh create groups/$campus_ops_id/children -r netcicd -s name="Campus Operators" &>CAMPUS_OPS_OPER
campus_ops_oper_id=$(cat CAMPUS_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created Campus Operator Group within Campus Operations Group with ID: ${campus_ops_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_ops_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_ops_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_ops_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Campus Operators."

./kcadm.sh create groups/$campus_ops_id/children -r netcicd -s name="Campus Specialist" &>CAMPUS_OPS_SPEC
campus_ops_spec_id=$(cat CAMPUS_OPS_SPEC | grep id | cut -d"'" -f 2)
echo "Created Campus Specialists Group within Campus Operations Group with ID: ${campus_ops_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_ops_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_ops_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_ops_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to Operations Campus Specialists."

./kcadm.sh create groups/$dom_campus_id/children -r netcicd -s name="2 - Campus Development" &>CAMPUS_DEV
campus_dev_id=$(cat CAMPUS_DEV | grep id | cut -d"'" -f 2)
echo "Created Campus Development Group with ID: ${campus_dev_id}" 

./kcadm.sh create groups/$campus_dev_id/children -r netcicd -s name="Campus LAN Designer" &>CAMPUS_DEV_LAN_DESIGNER
campus_dev_lan_designer_id=$(cat CAMPUS_DEV_LAN_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created Campus LAN Designer group within the Development Department with ID: ${campus_dev_lan_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_dev_lan_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_dev_lan_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_dev_lan_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Campus Designers."

./kcadm.sh create groups/$campus_dev_id/children -r netcicd -s name="Campus wifi Designer" &>CAMPUS_DEV_WIFI_DESIGNER
campus_dev_wifi_designer_id=$(cat CAMPUS_DEV_WIFI_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created Campus wifi Designer group within the Development Department with ID: ${campus_dev_wifi_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_dev_wifi_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_dev_wifi_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $campus_dev_wifi_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Campus Designers."

./kcadm.sh create groups -r netcicd -s name="WAN" &>DOM_WAN
dom_wan_id=$(cat DOM_WAN | grep id | cut -d"'" -f 2)
echo "Created WAN Domain with ID: ${dom_wan_id}" 

./kcadm.sh create groups/$dom_wan_id/children -r netcicd -s name="1 - WAN Operations" &>WAN_OPS
wan_ops_id=$(cat WAN_OPS | grep id | cut -d"'" -f 2)
echo "Created WAN Operations Group with ID: ${wan_ops_id}" 

./kcadm.sh create groups/$wan_ops_id/children -r netcicd -s name="WAN Operators" &>WAN_OPS_OPER
wan_ops_oper_id=$(cat WAN_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created WAN Operator Group within WAN Operations Group with ID: ${wan_ops_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_ops_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_ops_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_ops_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to WAN Operators."

./kcadm.sh create groups/$wan_ops_id/children -r netcicd -s name="WAN Specialist" &>WAN_OPS_SPEC
wan_ops_spec_id=$(cat WAN_OPS_SPEC | grep id | cut -d"'" -f 2)
echo "Created WAN Specialists Group within WAN Operations Group with ID: ${wan_ops_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_ops_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_ops_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_ops_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to Operations WAN Specialists."

./kcadm.sh create groups/$dom_wan_id/children -r netcicd -s name="2 - WAN Development" &>WAN_DEV
wan_dev_id=$(cat WAN_DEV | grep id | cut -d"'" -f 2)
echo "Created WAN Development Group with ID: ${wan_dev_id}" 

./kcadm.sh create groups/$wan_dev_id/children -r netcicd -s name="WAN Designer" &>WAN_DEV_DESIGNER
wan_dev_designer_id=$(cat WAN_DEV_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created WAN Designer group within the WAN Development Group with ID: ${wan_dev_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_dev_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_dev_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wan_dev_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to WAN Designer."

./kcadm.sh create groups -r netcicd -s name="Datacenter" &>DOM_DC
dom_dc_id=$(cat DOM_DC | grep id | cut -d"'" -f 2)
echo "Created Datacenter Domain with ID: ${dom_dc_id}" 

./kcadm.sh create groups/$dom_dc_id/children -r netcicd -s name="1 - Datacenter Operations" &>DC_OPS
dc_ops_id=$(cat DC_OPS | grep id | cut -d"'" -f 2)
echo "Created Datacenter Operations Group with ID: ${dc_ops_id}" 

./kcadm.sh create groups/$dc_ops_id/children -r netcicd -s name="1 - Compute" &>DC_OPS_COMP
dc_ops_comp_id=$(cat DC_OPS_COMP | grep id | cut -d"'" -f 2)
echo "Created Datacenter Operations Compute Group with ID: ${dc_ops_comp_id}" 

./kcadm.sh create groups/$dc_ops_comp_id/children -r netcicd -s name="Compute Operators" &>DC_OPS_COMP_OPER
dc_ops_comp_oper_id=$(cat DC_OPS_COMP_OPER | grep id | cut -d"'" -f 2)
echo "Created Compute Operator Group within Compute Operations Group with ID: ${dc_ops_comp_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_comp_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_comp_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_comp_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Compute Operators."

./kcadm.sh create groups/$dc_ops_comp_id/children -r netcicd -s name="Compute Specialist" &>DC_OPS_COMP_SPEC
dc_ops_comp_spec_id=$(cat DC_OPS_COMP_SPEC | grep id | cut -d"'" -f 2)
echo "Created Compute Specialists group within Compute Operations with ID: ${dc_ops_comp_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_comp_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_comp_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_comp_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to Compute Specialists."

./kcadm.sh create groups/$dc_ops_id/children -r netcicd -s name="2 - Network" &>DC_OPS_NET
dc_ops_net_id=$(cat DC_OPS_NET | grep id | cut -d"'" -f 2)
echo "Created Datacenter Network Operations Group with ID: ${dc_ops_net_id}" 

./kcadm.sh create groups/$dc_ops_net_id/children -r netcicd -s name="DC Network Operators" &>DC_OPS_NET_OPER
dc_ops_net_oper_id=$(cat DC_OPS_NET_OPER | grep id | cut -d"'" -f 2)
echo "Created DC Network Operator Group within DC Network Operations Group with ID: ${dc_ops_net_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_net_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_net_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_net_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to DC Network Operators."

./kcadm.sh create groups/$dc_ops_net_id/children -r netcicd -s name="DC Network Specialist" &>DC_OPS_NET_SPEC
dc_ops_net_spec_id=$(cat DC_OPS_NET_SPEC | grep id | cut -d"'" -f 2)
echo "Created DC Network Specialists group within Compute Operations with ID: ${dc_ops_net_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_net_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_net_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_net_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to DC Network Specialists."

./kcadm.sh create groups/$dc_ops_id/children -r netcicd -s name="3 - Storage" &>DC_OPS_STOR
dc_ops_stor_id=$(cat DC_OPS_STOR | grep id | cut -d"'" -f 2)
echo "Created Datacenter Operations Group with ID: ${dc_ops_stor_id}" 

./kcadm.sh create groups/$dc_ops_stor_id/children -r netcicd -s name="Storage Operators" &>DC_OPS_STOR_OPER
dc_ops_stor_oper_id=$(cat DC_OPS_STOR_OPER | grep id | cut -d"'" -f 2)
echo "Created Storage Operator Group within Storage Operations Group with ID: ${dc_ops_stor_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_stor_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_stor_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_stor_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Storage Operators."

./kcadm.sh create groups/$dc_ops_stor_id/children -r netcicd -s name="Storage Specialist" &>DC_OPS_STOR_SPEC
dc_ops_stor_spec_id=$(cat DC_OPS_STOR_SPEC | grep id | cut -d"'" -f 2)
echo "Created Storage Specialists group within Storage Operations with ID: ${dc_ops_stor_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_stor_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_stor_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_ops_stor_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to Storage Specialists."

./kcadm.sh create groups/$dom_dc_id/children -r netcicd -s name="2 - Datacenter Development" &>DC_DEV
dc_dev_id=$(cat DC_DEV | grep id | cut -d"'" -f 2)
echo "Created Datacenter Development Group with ID: ${dc_dev_id}" 

./kcadm.sh create groups/$dc_dev_id/children -r netcicd -s name="DC Compute Designer" &>DC_DEV_COMPUTE_DESIGNER
dc_dev_compute_designer_id=$(cat DC_DEV_COMPUTE_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created Compute Designer Group within the Datacenter Development Group with ID: ${dc_dev_compute_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_compute_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_compute_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_compute_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to DC Compute Designers."

./kcadm.sh create groups/$dc_dev_id/children -r netcicd -s name="DC Network Designer" &>DC_DEV_NETWORK_DESIGNER
dc_dev_network_designer_id=$(cat DC_DEV_NETWORK_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created DC Network Group within the Datacenter Development Group with ID: ${dc_dev_network_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_network_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_network_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_network_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to DC Network Designers."

./kcadm.sh create groups/$dc_dev_id/children -r netcicd -s name="DC Storage Designer" &>DC_DEV_STORAGE_DESIGNER
dc_dev_storage_designer_id=$(cat DC_DEV_STORAGE_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created DC Storage Designer Group within the Datacenter Development Group with ID: ${dc_dev_storage_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_storage_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_storage_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dc_dev_storage_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to DC Network Designers."

./kcadm.sh create groups -r netcicd -s name="Aplications" &>DOM_APPS
dom_apps_id=$(cat DOM_APPS | grep id | cut -d"'" -f 2)
echo "Created Applications Domain with ID: ${dom_apps_id}" 

./kcadm.sh create groups/$dom_apps_id/children -r netcicd -s name="1 - Application Operations" &>APP_OPS
app_ops_id=$(cat APP_OPS | grep id | cut -d"'" -f 2)
echo "Created Application Operations Group with ID: ${app_ops_id}" 

./kcadm.sh create groups/$dom_apps_id/children -r netcicd -s name="2 - Application Development" &>APP_DEV
app_dev_id=$(cat APP_DEV | grep id | cut -d"'" -f 2)
echo "Created Application Development Group with ID: ${app_dev_id}" 

./kcadm.sh create groups -r netcicd -s name="Tooling" &>DOM_TOOLING
dom_tooling_id=$(cat DOM_TOOLING | grep id | cut -d"'" -f 2)
echo "Created Tooling Domain with ID: ${dom_tooling_id}" 

./kcadm.sh create groups/$dom_tooling_id/children -r netcicd -s name="1 - Tooling Operations" &>TOOL_OPS
tool_ops_id=$(cat TOOL_OPS | grep id | cut -d"'" -f 2)
echo "Created Tooling Operations Group with ID: ${tool_ops_id}" 

./kcadm.sh create groups/$tool_ops_id/children -r netcicd -s name="Tooling Operator" &>TOOL_OPS_OPER
tool_ops_oper_id=$(cat TOOL_OPS_OPER | grep id | cut -d"'" -f 2)
echo "Created Tooling Operator group within the Tooling Operations Department with ID: ${tool_ops_oper_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_ops_oper_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_ops_oper_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_ops_oper_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Tooling Operator."

./kcadm.sh create groups/$tool_ops_id/children -r netcicd -s name="Tooling Specialist" &>TOOL_OPS_SPEC
tool_ops_spec_id=$(cat TOOL_OPS_SPEC | grep id | cut -d"'" -f 2)
echo "Created Tooling Specialist group within the Tooling Operations Department with ID: ${tool_ops_spec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_ops_spec_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_ops_spec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-cicdtoolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_ops_spec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Tooling Operator."

./kcadm.sh create groups/$dom_tooling_id/children -r netcicd -s name="2 - Tooling Development" &>TOOL_DEV
tool_dev_id=$(cat TOOL_DEV | grep id | cut -d"'" -f 2)
echo "Created Tooling Development Group with ID: ${tool_dev_id}" 

./kcadm.sh create groups/$tool_dev_id/children -r netcicd -s name="Tooling Designer" &>TOOL_DEV_DESIGNER
tool_dev_designer_id=$(cat TOOL_DEV_DESIGNER | grep id | cut -d"'" -f 2)
echo "Created Tooling Designer Group within the Tooling Department with ID: ${tool_dev_designer_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_dev_designer_id \
    --cclientid Gitea \
    --rolename gitea-netcicd-read \
    --rolename gitea-cicdtoolbox-write

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_dev_designer_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-cicdtoolbox-dev 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tool_dev_designer_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Tooling Designer."

./kcadm.sh create groups -r netcicd -s name="Security" &>DOM_SEC
dom_sec_id=$(cat DOM_SEC | grep id | cut -d"'" -f 2)
echo "Created Security Domain with ID: ${dom_sec_id}" 

./kcadm.sh create groups/$dom_sec_id/children -r netcicd -s name="1 - Security Operations" &>SEC_OPS
sec_ops_id=$(cat SEC_OPS | grep id | cut -d"'" -f 2)
echo "Created Security Operations Group with ID: ${sec_ops_id}" 

./kcadm.sh create groups/$dom_sec_id/children -r netcicd -s name="2 - Security Development" &>SEC_DEV
sec_dev_id=$(cat SEC_DEV | grep id | cut -d"'" -f 2)
echo "Created Security Development Group with ID: ${sec_dev_id}" 

./kcadm.sh create groups -r netcicd -s name="Field Services" &>DOM_FS
dom_fs_id=$(cat DOM_FS | grep id | cut -d"'" -f 2)
echo "Created Field Services Domain with ID: ${dom_fs_id}" 

./kcadm.sh create groups/$dom_fs_id/children -r netcicd -s name="1 - Field Service Engineers" &>FS_FSE
fs_fse_id=$(cat FS_FSE | grep id | cut -d"'" -f 2)
echo "Created Field Service Engineers group within the Field Services Department with ID: ${fs_fse_id}" 

./kcadm.sh create groups/$dom_fs_id/children -r netcicd -s name="2 - Floor Management" &>FS_FM
fs_fm_id=$(cat FS_FM | grep id | cut -d"'" -f 2)
echo "Created Floor Management group within the Field Services Department with ID: ${fs_fm_id}" 


#add users
./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=netcicd \
    -s firstName=NetCICD \
    -s lastName=Godmode \
    -s email=netcicd@tooling.test
./kcadm.sh set-password -r netcicd --username netcicd --new-password netcicd
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Gitea --rolename gitea-infraautomators-admin
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Jenkins --rolename jenkins-admin
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Nexus --rolename nexus-admin
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Nexus --rolename nexus-docker-pull
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Nexus --rolename nexus-docker-push

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=git-jenkins \
    -s firstName=Jenkins \
    -s lastName=Butler \
    -s email=git-jenkins@tooling.test


./kcadm.sh set-password -r netcicd --username git-jenkins --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Gitea --rolename gitea-netcicd-write
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Jenkins --rolename jenkins-git

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=jenkins-jenkins \
    -s firstName=Jenkins \
    -s lastName=Jenkins \
    -s email=jenkins-jenkins@tooling.test

./kcadm.sh set-password -r netcicd --username jenkins-jenkins --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername jenkins-jenkins --cclientid Jenkins --rolename jenkins-netcicd-agent

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=netcicd-pipeline\
    -s firstName=NetCICD \
    -s lastName=Pipeline \
    -s email=netcicd-pipeline@tooling.test

./kcadm.sh set-password -r netcicd --username netcicd-pipeline --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername netcicd-pipeline --cclientid Nexus --rolename nexus-apk-read
./kcadm.sh add-roles -r netcicd  --uusername netcicd-pipeline --cclientid Nexus --rolename nexus-netcicd-agent


./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=thedude \
    -s firstName=The \
    -s lastName=Dude \
    -s email=thedude@tooling.test &>NetCICD_THEDUDE
dude_id=$(cat NetCICD_THEDUDE | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username thedude --new-password thedude

./kcadm.sh update users/$dude_id/groups/$campus_ops_oper_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$dude_id \
    -s groupId=$campus_ops_oper_id \
    -n

./kcadm.sh update users/$dude_id/groups/$wan_ops_oper_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$dude_id \
    -s groupId=$wan_ops_oper_id \
    -n

./kcadm.sh update users/$dude_id/groups/$dc_ops_net_oper_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$dude_id \
    -s groupId=$dc_ops_net_oper_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=thespecialist \
    -s firstName=The \
    -s lastName=Specialist \
    -s email=thespecialist@tooling.test &>NetCICD_THESPEC

spec_id=$(cat NetCICD_THESPEC | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username thespecialist --new-password thespecialist

./kcadm.sh update users/$spec_id/groups/$campus_ops_spec_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$spec_id \
    -s groupId=$campus_ops_spec_id \
    -n

./kcadm.sh update users/$spec_id/groups/$wan_ops_spec_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$spec_id \
    -s groupId=$wan_ops_spec_id \
    -n

./kcadm.sh update users/$spec_id/groups/$dc_ops_net_spec_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$spec_id \
    -s groupId=$dc_ops_net_spec_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=thearchitect \
    -s firstName=The \
    -s lastName=Architect \
    -s email=thearchitect@tooling.test &>NetCICD_ARCH

arch_id=$(cat NetCICD_ARCH | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username architect --new-password architect

./kcadm.sh update users/$arch_id/groups/$dc_dev_compute_designer_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$dc_dev_compute_designer_id \
    -n

./kcadm.sh update users/$arch_id/groups/$dc_dev_network_designer_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$dc_dev_network_designer_id \
    -n

./kcadm.sh update users/$arch_id/groups/$campus_dev_lan_designer_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$campus_dev_lan_designer_id \
    -n

./kcadm.sh update users/$arch_id/groups/$campus_dev_wifi_designer_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$campus_dev_wifi_designer_id \
    -n

./kcadm.sh update users/$arch_id/groups/$wan_dev_designer_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$wan_dev_designer_id \
    -n

./kcadm.sh update users/$arch_id/groups/$dc_dev_storage_designer_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$dc_dev_storage_designer_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=happyhacker \
    -s firstName=Happy \
    -s lastName=Hacker \
    -s email=happyhacker@tooling.test &>NetCICD_HACKER

hack_id=$(cat NetCICD_HACKER | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username hacker --new-password whitehat

./kcadm.sh update users/$hack_id/groups/$tool_ops_oper_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$hack_id \
    -s groupId=$tool_ops_oper_id \
    -n

./kcadm.sh update users/$hack_id/groups/$tool_ops_spec_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$hack_id \
    -s groupId=$tool_ops_spec_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=tooltiger \
    -s firstName=Tool \
    -s lastName=Tiger \
    -s email=tooltiger@tooling.test &>NetCICD_TOOLTIGER

tooltiger_id=$(cat NetCICD_TOOLTIGER | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username tooltiger --new-password tooltiger

./kcadm.sh update users/$tooltiger_id/groups/$tool_dev_designer_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$tooltiger_id \
    -s groupId=$tool_dev_designer_id \
    -n

#Now delete tokens and secrets
rm NetCICD_*

# Add FreeIPA integration
./kcadm.sh create components -r netcicd \
    -s name=freeipa \
    -s providerId=ldap \
    -s providerType=org.keycloak.storage.UserStorageProvider \
    -s 'config.priority=["1"]' \
    -s 'config.editMode=["READ_ONLY"]' \
    -s 'config.syncRegistrations=["false"]' \
    -s 'config.vendor=["Red Hat Directory Server"]' \
    -s 'config.usernameLDAPAttribute=["uid"]' \
    -s 'config.rdnLDAPAttribute=["uid"]' \
    -s 'config.uuidLDAPAttribute=["ipaUniqueID"]' \
    -s 'config.userObjectClasses=["inetOrgPerson, organizationalPerson"]' \
    -s 'config.connectionUrl=["ldap://freeipa.tooling.test"]' \
    -s 'config.usersDn=["cn=users,cn=accounts,dc=tooling,dc=test"]' \
    -s 'config.searchScope=["1"]' \
    -s 'config.authType=["simple"]' \
    -s 'config.bindDn=["uid=binduser,cn=sysaccounts,cn=etc,dc=tooling,dc=test"]' \
    -s 'config.bindCredential=["secret"]' \
    -s 'config.useTruststoreSpi=["ldapsOnly"]' \
    -s 'config.pagination=["true"]' \
    -s 'config.connectionPooling=["true"]' \
    -s 'config.allowKerberosAuthentication=["true"]' \
    -s 'config.kerberosRealm=["tooing.test"]' \
    -s 'config.serverPrincipal=["HTTP/keycloak.tooling.test"]' \
    -s 'config.keyTab=["/etc/krb5-keycloak.keytab"]' \
    -s 'config.debug=["false"]' \
    -s 'config.useKerberosForPasswordAuthentication=["true"]' \
    -s 'config.batchSizeForSync=["1000"]' \
    -s 'config.fullSyncPeriod=["-1"]' \
    -s 'config.changedSyncPeriod=["-1"]' \
    -s 'config.cachePolicy=["DEFAULT"]' \
    -s config.evictionDay=[] \
    -s config.evictionHour=[] \
    -s config.evictionMinute=[] \
    -s config.maxLifespan=[] 

