#!/bin/bash
# shell script to be copied into /opt/jboss/keycloak/bin
cd /opt/jboss/keycloak/bin
rm Net*
#Create credentials
./kcadm.sh config credentials --server http://keycloak:8080/auth --realm master --user admin --password Pa55w0rd

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
    -s rootUrl=http://gitea:3000 \
    -s adminUrl=http://gitea:3000/ \
    -s 'redirectUris=[ "http://gitea:3000/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "http://gitea:3000/" ]' \
    -o --fields id >NetCICD_GITEA

# output is Created new client with id, we now need to grep the ID out of it
GITEA_ID=$(cat NetCICD_GITEA | grep id | cut -d'"' -f 4)
echo "Created Gitea client with ID: ${GITEA_ID}" 
echo " "
# Create Client secret
./kcadm.sh create clients/$GITEA_ID/client-secret -r netcicd

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$GITEA_ID/client-secret -r netcicd >NetCICD_gitea_secret
GITEA_token=$(grep value NetCICD_gitea_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "GITEA_token: ${GITEA_token}"

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-infraautomators-admin -s description='The admin role for the Infra Automators organization'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netops-read -s description='A read-only role for network operations, intended for users/operators'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netops-write -s description='A read-write role for network operations, intended for network specialists'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netdev-read -s description='A read-only role for network development, intended for network architects'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netdev-write -s description='A read-write role for network development, intended for network senior network architects'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-tooling-read -s description='A read-only role for the tooling team, intended for developers that do not alter platform specific workflows'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-tooling-write -s description='A read-write role for the tooling team, intended for senior developers of the tooling team'

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
    -s rootUrl=http://jenkins:8080 \
    -s adminUrl=http://jenkins:8080/ \
    -s 'redirectUris=[ "http://jenkins:8080/*" ]' \
    -s 'webOrigins=[ "http://jenkins:8080/" ]' \
    -o --fields id >NetCICD_JENKINS

# output is Created new client with id, we now need to grep the ID out of it
JENKINS_ID=$(cat NetCICD_JENKINS | grep id | cut -d'"' -f 4)
echo "Created Jenkins client with ID: ${JENKINS_ID}" 
echo " "
# Create Client secret
./kcadm.sh create clients/$JENKINS_ID/client-secret -r netcicd

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$JENKINS_ID/client-secret -r netcicd >NetCICD_jenkins_secret
JENKINS_token=$(grep value NetCICD_jenkins_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "JENKINS_token: ${JENKINS_token}"
echo " "

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-admin -s description='The admin role for Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-user -s description='A user in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-readonly -s description='A viewer in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-agent -s description='The role to be used for a user that needs to create agents in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-run -s description='The role to be used for a user that needs to run the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-dev -s description='The role to be used for a user that needs to configure the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-toolbox-run -s description='The role to be used for a user that needs to run the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-toolbox-dev -s description='The role to be used for a user that needs to configure the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-git -s description='A role for Jenkins to work with Git'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-argos -s description='A role for Jenkins to create logs in Argos'

echo "Created Jenkins roles." 

# Now we need a service account for other systems to log into Jenkins
./kcadm.sh add-roles -r netcicd --uusername service-account-jenkins --cclientid realm-management --rolename view-clients --rolename view-realm --rolename view-users

echo "Created Jenkins Service Account" 
echo " "

# We need to add a client scope on the realm for Jenkins in order to include the audience in the access token
./kcadm.sh create -x "client-scopes" -r netcicd -s name=jenkins-audience -s protocol=openid-connect &>NetCICD_JENKINS_SCOPE
JENKINS_SCOPE_ID=$(cat NetCICD_JENKINS_SCOPE | grep id | cut -d"'" -f 2)
echo "Created Client scope for Jenkins with id: ${JENKINS_SCOPE_ID}" 
echo " "

# Create a mapper for the audience
./kcadm.sh create clients/$JENKINS_ID/protocol-mappers/models \
    -r netcicd \
	-s name=jenkins-audience-mapper \
    -s protocol=openid-connect \
	-s protocolMapper=oidc-audience-mapper \
    -s consentRequired=false \
	-s config="{\"included.client.audience\" : \"Jenkins\",\"id.token.claim\" : \"false\",\"access.token.claim\" : \"true\"}"

echo "Created audience mapper in the Client Scope" 
echo " "

# We need to add the scope to the token
./kcadm.sh update clients/$JENKINS_ID -r netcicd --body "{\"defaultClientScopes\": [\"jenkins-audience\"]}"

echo "Included Jenkins Audience in token" 
echo " "

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
#echo " "

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
    -s rootUrl=http://nexus:8081 \
    -s adminUrl=http://nexus:8081/ \
    -s 'redirectUris=[ "http://nexus:8081/*" ]' \
    -s 'webOrigins=[ "http://nexus:8081/" ]' \
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
echo " "

# Now add the scope mappings for Nexus
RM_ID=$( ./kcadm.sh get -r netcicd clients | grep realm-management -B1 | grep id | awk -F',' '{print $(1)}' | cut -d ' ' -f5 | cut -d '"' -f2 )
echo $RM_ID
./kcadm.sh create -r netcicd clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-realm\"}]"
./kcadm.sh create -r netcicd clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-users\"}]"
./kcadm.sh create -r netcicd clients/$NEXUS_ID/scope-mappings/clients/$RM_ID  --body "[{\"name\": \"view-clients\"}]"

# Service account
./kcadm.sh add-roles -r netcicd --uusername service-account-nexus --cclientid account --rolename manage-account --rolename manage-account-links --rolename view-profile
./kcadm.sh add-roles -r netcicd --uusername service-account-nexus --cclientid Nexus --rolename uma_protection
./kcadm.sh add-roles -r netcicd --uusername service-account-nexus --cclientid realm-management --rolename view-clients --rolename view-realm --rolename view-users

echo "Created Nexus Service Account" 
echo " "

#download Nexus OIDC file
./kcadm.sh get clients/$NEXUS_ID/installation/providers/keycloak-oidc-keycloak-json -r netcicd > keycloak-nexus.json

echo "Created keycloak-nexus installation json" 
echo " "

./kcadm.sh create clients \
    -r netcicd \
    -s name="RADIUS" \
    -s description="The FreeRADIUS server in the toolchain" \
    -s clientId=RADIUS \
    -s enabled=true \
    -s publicClient=true \
    -s protocol=radius-protocol \
    -s directAccessGrantsEnabled=true \
    -s 'redirectUris=[ "*" ]' \
    -o --fields id >NetCICD_RADIUS

# output is Created new client with id, we now need to grep the ID out of it
RADIUS_ID=$(cat NetCICD_RADIUS | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$RADIUS_ID/roles -r netcicd -s name=RADIUS-admin -s description='The admin role for FreeRADIUS'
./kcadm.sh create clients/$RADIUS_ID/roles -r netcicd -s name=RADIUS-LAN-client -s description='A role to be used for 802.1x authentication on switch ports'
./kcadm.sh create clients/$RADIUS_ID/roles -r netcicd -s name=RADIUS-network-admin -s description='An admin role to be used for RADIUS based AAA on Cisco routers'
./kcadm.sh create clients/$RADIUS_ID/roles -r netcicd -s name=RADIUS-network-operator -s description='A role to be used for RADIUS based AAA on Cisco routers'
./kcadm.sh create clients/$RADIUS_ID/roles -r netcicd -s name=RADIUS-ACCEPT-ROLE -s description='A test role to be used for RADIUS based AAA'
./kcadm.sh create clients/$RADIUS_ID/roles -r netcicd -s name=RADIUS-REJECT-ROLE -s description='A test role to be used for RADIUS based AAA'
 
 #now add attributes (it does not work when entered directly)
 ./kcadm.sh update clients/$RADIUS_ID/roles/RADIUS-REJECT-ROLE -r netcicd -s 'attributes.REJECT_RADIUS=["true"]'

./kcadm.sh create clients \
    -r netcicd \
    -s name="TACACS" \
    -s description="The TACACS+ server in the toolchain" \
    -s clientId=TACACS \
    -s enabled=true \
    -s publicClient=true \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://tacacs:49 \
    -s adminUrl=http://tacacs:49/ \
    -s 'redirectUris=[ "http://tacacs:49/*" ]' \
    -s 'webOrigins=[ "http://tacacs:49/" ]' \
    -o --fields id >NetCICD_TACACS

# output is Created new client with id, we now need to grep the ID out of it
TACACS_ID=$(cat NetCICD_TACACS | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$TACACS_ID/roles -r netcicd -s name=TACACS-admin -s description='The admin role for FreeRADIUS'
./kcadm.sh create clients/$TACACS_ID/roles -r netcicd -s name=TACACS-network-admin -s description='An admin role to be used for RADIUS based AAA on Cisco routers, priv 15'
./kcadm.sh create clients/$TACACS_ID/roles -r netcicd -s name=TACACS-network-operator -s description='A role to be used for RADIUS based AAA on Cisco routers, priv 2'

./kcadm.sh create clients \
    -r netcicd \
    -s name="Argos" \
    -s description="The Argos notary in the toolchain" \
    -s clientId=Argos \
    -s enabled=true \
    -s publicClient=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://argos \
    -s adminUrl=http://argos/ \
    -s 'redirectUris=[ "http://argos/*" ]' \
    -s 'webOrigins=[ "http://argos/" ]' \
    -o --fields id >NetCICD_ARGOS

# output is Created new client with id, we now need to grep the ID out of it
ARGOS_ID=$(cat NetCICD_ARGOS | grep id | cut -d'"' -f 4)
echo "Created Argos client with ID: ${ARGOS_ID}" localhost# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$ARGOS_ID/roles -r netcicd -s name=argos-admin -s description='The admin role for Argos'
./kcadm.sh create clients/$ARGOS_ID/roles -r netcicd -s name=argos-user -s description='The user role for Argos'
./kcadm.sh create clients/$ARGOS_ID/roles -r netcicd -s name=argos-jenkins -s description='The jenkins user role for Argos'

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$ARGOS_ID/client-secret -r netcicd >NetCICD_argos_secret
ARGOS_token=$(grep value NetCICD_argos_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "ARGOS_token: " $ARGOS_token

#add groups - we start at the system level, which implements the groups related to service accounts
./kcadm.sh create groups -r netcicd -s name="System" &>NetCICD_SYSTEM
system_id=$(cat NetCICD_SYSTEM | grep id | cut -d"'" -f 2)
echo "Created System Group with ID: ${system_id}" 
echo " "

./kcadm.sh create groups/$system_id/children -r netcicd -s name="jenkins-git" &>NetCICD_J_G
j_g_id=$(cat NetCICD_J_G | grep id | cut -d"'" -f 2)
echo "Created jenkins-git group with ID: ${j_g_id}" 
echo " "

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $j_g_id \
    --cclientid Jenkins \
    --rolename jenkins-git

#add groups - we start at the ICT infra level, which implements the capacity layer of the MyREFerence model
./kcadm.sh create groups -r netcicd -s name="Infra" &>NetCICD_INFRA
infra_id=$(cat NetCICD_INFRA | grep id | cut -d"'" -f 2)
echo "Created Infra Department with ID: ${infra_id}" 
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Operations" &>NetCICD_OPS
ops_id=$(cat NetCICD_OPS | grep id | cut -d"'" -f 2)
echo "Created Operations Department with ID: ${ops_id}" 
echo " "

./kcadm.sh create groups/$ops_id/children -r netcicd -s name="Field Services" &>NetCICD_FS
field_services_id=$(cat NetCICD_FS | grep id | cut -d"'" -f 2)
echo "Created Field Services Department with ID: ${field_services_id}" 

./kcadm.sh create groups/$field_services_id/children -r netcicd -s name="Field Service Engineers" &>NetCICD_FSE
fse_id=$(cat NetCICD_FSE | grep id | cut -d"'" -f 2)
echo "Created Field Service Engineers group within the Field Services Department with ID: ${fse_id}" 
echo " "

./kcadm.sh create groups/$ops_id/children -r netcicd -s name="Network" &>NetCICD_NET
network_id=$(cat NetCICD_NET | grep id | cut -d"'" -f 2)
echo "Created Network Department with ID: ${network_id}" 

./kcadm.sh create groups/$network_id/children -r netcicd -s name="Campus" &>NetCICD_CAMPUS
campus_id=$(cat NetCICD_CAMPUS | grep id | cut -d"'" -f 2)
echo "Created Campus Network Department within the Network Department with ID: ${campus_id}" 

./kcadm.sh create groups/$campus_id/children -r netcicd -s name="Campus-operators" &>NetCICD_CAMOPS
camops_id=$(cat NetCICD_CAMOPS | grep id | cut -d"'" -f 2)
echo "Created Campus Operator group within Campus Operations with ID: ${camops_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $camops_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-read 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $camops_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $camops_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Campus Operators."
echo " "

./kcadm.sh create groups/$campus_id/children -r netcicd -s name="Campus-specialist" &>NetCICD_CAMSPEC
camspec_id=$(cat NetCICD_CAMSPEC | grep id | cut -d"'" -f 2)
echo "Created Campus Specialists group within Campus Operations with ID: ${camspec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $camspec_id \
    --cclientid Gitea \
    --rolename gitea-netops-write \
    --rolename gitea-netdev-read \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $camspec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $camspec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to Operations Campus Specialists."
echo " "

./kcadm.sh create groups/$network_id/children -r netcicd -s name="WAN" &>NetCICD_WAN
wan_id=$(cat NetCICD_WAN | grep id | cut -d"'" -f 2)
echo "Created WAN Network Department within the Network Department with ID: ${wan_id}" 

./kcadm.sh create groups/$wan_id/children -r netcicd -s name="WAN-operators" &>NetCICD_WANOPS
wanops_id=$(cat NetCICD_WANOPS | grep id | cut -d"'" -f 2)
echo "Created WAN Operator group within WAN Operations with ID: ${wanops_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanops_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-read \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanops_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanops_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to WAN Operators."
echo " "

./kcadm.sh create groups/$wan_id/children -r netcicd -s name="WAN-specialist" &>NetCICD_WANSPEC
wanspec_id=$(cat NetCICD_WANSPEC | grep id | cut -d"'" -f 2)
echo "Created WAN Specialists group within WAN Operations with ID: ${wanspec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanspec_id \
    --cclientid Gitea \
    --rolename gitea-netops-write \
    --rolename gitea-netdev-read \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanspec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanspec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to Operations WAN Specialists."
echo " "

./kcadm.sh create groups/$network_id/children -r netcicd -s name="Datacenter" &>NetCICD_DC
dc_id=$(cat NetCICD_DC | grep id | cut -d"'" -f 2)
echo "Created DC Network Department within the Network Department with ID: ${dc_id}" 

./kcadm.sh create groups/$dc_id/children -r netcicd -s name="DC-operators" &>NetCICD_DCOPS
dcops_id=$(cat NetCICD_DCOPS | grep id | cut -d"'" -f 2)
echo "Created DC Operator group within DC Operations with ID: ${dcops_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcops_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-read \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcops_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcops_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to DC Operators."
echo " "

./kcadm.sh create groups/$dc_id/children -r netcicd -s name="DC-specialist" &>NetCICD_DCSPEC
dcspec_id=$(cat NetCICD_DCSPEC | grep id | cut -d"'" -f 2)
echo "Created DC Specialists group within DC Operations with ID: ${dcspec_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcspec_id \
    --cclientid Gitea \
    --rolename gitea-netops-write \
    --rolename gitea-netdev-read \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcspec_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcspec_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
echo "Added roles to Operations DC Specialists."
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Compute" &>NetCICD_COMPUTE
compute_id=$(cat NetCICD_COMPUTE | grep id | cut -d"'" -f 2)
echo "Created Compute Department with ID: ${compute_id}" 

./kcadm.sh create groups/$compute_id/children -r netcicd -s name="Container" &>NetCICD_CONTAINER
container_id=$(cat NetCICD_CONTAINER | grep id | cut -d"'" -f 2)
echo "Created Container Department within the Compute Department with ID: ${container_id}" 

./kcadm.sh create groups/$container_id/children -r netcicd -s name="Container operators" &>NetCICD_CTOPS
ctops_id=$(cat NetCICD_CTOPS | grep id | cut -d"'" -f 2)
echo "Created Container Operator group within the Container group with ID: ${ctops_id}" 

./kcadm.sh create groups/$container_id/children -r netcicd -s name="Container-specialist" &>NetCICD_CTSPEC
ctspec_id=$(cat NetCICD_CTSPEC | grep id | cut -d"'" -f 2)
echo "Created Container specialist group within the Container group with ID: ${ctspec_id}" 
echo " "

./kcadm.sh create groups/$compute_id/children -r netcicd -s name="VM" &>NetCICD_VM
vm_id=$(cat NetCICD_VM | grep id | cut -d"'" -f 2)
echo "Created VM Department within the Compute Department with ID: ${vm_id}" 

./kcadm.sh create groups/$vm_id/children -r netcicd -s name="VM-operators" &>NetCICD_VMOPS
vmops_id=$(cat NetCICD_VMOPS | grep id | cut -d"'" -f 2)
echo "Created VM Operator group within the VM group with ID: ${vmops_id}" 

./kcadm.sh create groups/$vm_id/children -r netcicd -s name="VM-specialist" &>NetCICD_VMSPEC
vmspec_id=$(cat NetCICD_VMSPEC | grep id | cut -d"'" -f 2)
echo "Created VM Specialist group within the VM group with ID: ${vmspec_id}" 
echo " "

./kcadm.sh create groups/$compute_id/children -r netcicd -s name="Cloud" &>NetCICD_CL
cl_id=$(cat NetCICD_CL | grep id | cut -d"'" -f 2)
echo "Created Cloud Department within the Compute Department with ID: ${cl_id}" 

./kcadm.sh create groups/$cl_id/children -r netcicd -s name="Cloud-operators" &>NetCICD_CLOPS
clops_id=$(cat NetCICD_CLOPS | grep id | cut -d"'" -f 2)
echo "Created Cloud Operators group within the Cloud group with ID: ${clops_id}" 

./kcadm.sh create groups/$cl_id/children -r netcicd -s name="Cloud-specialist" &>NetCICD_CLSPEC
clspec_id=$(cat NetCICD_CLSPEC | grep id | cut -d"'" -f 2)
echo "Created Cloud Specialist group within the Cloud group with ID: ${clspec_id}" 
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Storage" &>NetCICD_STORAGE
storage_id=$(cat NetCICD_STORAGE | grep id | cut -d"'" -f 2)
echo "Created Storage Department with ID: ${storage_id}" 
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Development" &>NetCICD_DEV
dev_id=$(cat NetCICD_DEV | grep id | cut -d"'" -f 2)
echo "Created Development Department with ID: ${dev_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Campus-architect" &>NetCICD_CAMARCH
camarch_id=$(cat NetCICD_CAMARCH | grep id | cut -d"'" -f 2)
echo "Created Campus Architect group within the Development Department with ID: ${camarch_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $camarch_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-write \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $camarch_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $camarch_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Campus Architects."
echo " "

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="WAN-architect" &>NetCICD_WANARCH
wanarch_id=$(cat NetCICD_WANARCH | grep id | cut -d"'" -f 2)
echo "Created WAN Architect group within the Development Department with ID: ${wanarch_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanarch_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-write \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanarch_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $wanarch_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to WAN Architects."
echo " "

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="DC-architect" &>NetCICD_DCARCH
dcarch_id=$(cat NetCICD_DCARCH | grep id | cut -d"'" -f 2)
echo "Created DC Architect group within the Development Department with ID: ${dcarch_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcarch_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-write \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcarch_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $dcarch_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to DC Architects."
echo " "

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Storage-architect" &>NetCICD_STORARCH
storarch_id=$(cat NetCICD_STORARCH | grep id | cut -d"'" -f 2)
echo "Created Storage Architect group within the Development Department with ID: ${storarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Container-architect" &>NetCICD_CONTARCH
ctarch_id=$(cat NetCICD_CONTARCH | grep id | cut -d"'" -f 2)
echo "Created Container Architect group within the Development Department with ID: ${ctarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="VM Architect" &>NetCICD_VMARCH
vmarch_id=$(cat NetCICD_VMARCH | grep id | cut -d"'" -f 2)
echo "Created VM Architect group within the Development Department with ID: ${vmarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Cloud Architect" &>NetCICD_CLARCH
clarch_id=$(cat NetCICD_CLARCH | grep id | cut -d"'" -f 2)
echo "Created Cloud Architect group within the Development Department with ID: ${clarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Tooling Architect" &>NetCICD_TOOLARCH
toolarch_id=$(cat NetCICD_TOOLARCH | grep id | cut -d"'" -f 2)
echo "Created Tooling Architect group within the Development Department with ID: ${toolarch_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $toolarch_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-read \
    --rolename gitea-tooling-write \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $toolarch_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-toolbox-dev 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $toolarch_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read

echo "Added roles to Tooling Architect."
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Tooling" &>NetCICD_TOOL
tool_id=$(cat NetCICD_TOOL | grep id | cut -d"'" -f 2)
echo "Created Tooling Department with ID: ${tool_id}" 

./kcadm.sh create groups/$tool_id/children -r netcicd -s name="Tooling Operations" &>NetCICD_TOOLOPS
toolops_id=$(cat NetCICD_TOOLOPS | grep id | cut -d"'" -f 2)
echo "Created Tooling Operations group within the Tooling Department with ID: ${toolops_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $toolops_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-read \
    --rolename gitea-tooling-read \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $toolops_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $toolops_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-read
     
./kcadm.sh create groups/$tool_id/children -r netcicd -s name="Tooling Development" &>NetCICD_TOOLDEV
tooldev_id=$(cat NetCICD_TOOLDEV | grep id | cut -d"'" -f 2)
echo "Created Tooling Development group within the Tooling Department with ID: ${tooldev_id}" 
echo " "

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $tooldev_id \
    --cclientid Gitea \
    --rolename gitea-netops-read \
    --rolename gitea-netdev-read \
    --rolename gitea-tooling-write \

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tooldev_id \
    --cclientid Jenkins \
    --rolename jenkins-user \
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-dev 

./kcadm.sh add-roles \
    -r netcicd \
    --gid $tooldev_id \
    --cclientid Nexus \
    --rolename nexus-docker-pull \
    --rolename nexus-docker-push \
    --rolename nexus-read   

#add users
./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=netcicd \
    -s firstName=NetCICD \
    -s lastName=Godmode \
    -s email=netcicd@infraautomators.example.com
./kcadm.sh set-password -r netcicd --username netcicd --new-password netcicd
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Gitea --rolename gitea-infraautomators-admin
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Jenkins --rolename jenkins-admin
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Argos --rolename argos-admin
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Nexus --rolename nexus-admin
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Nexus --rolename nexus-docker-pull
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Nexus --rolename nexus-docker-push

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=git-jenkins \
    -s firstName=Jenkins \
    -s lastName=gitOperator \
    -s email=git-jenkins@infraautomators.example.com


./kcadm.sh set-password -r netcicd --username git-jenkins --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Gitea --rolename gitea-netops-write
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Jenkins --rolename jenkins-git

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=jenkins-jenkins \
    -s firstName=Jenkins \
    -s lastName=Jenkins \
    -s email=jenkins-jenkins@infraautomators.example.com

./kcadm.sh set-password -r netcicd --username jenkins-jenkins --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername jenkins-jenkins --cclientid Jenkins --rolename jenkins-netcicd-agent

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=jenkins-argos \
    -s firstName=Jenkins \
    -s lastName=Argos \
    -s email=jenkins-argos@infraautomators.example.com

./kcadm.sh set-password -r netcicd --username jenkins-argos --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername jenkins-argos --cclientid Jenkins --rolename jenkins-argos
./kcadm.sh add-roles -r netcicd  --uusername jenkins-argos --cclientid Argos --rolename argos-jenkins

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=netcicd-pipeline\
    -s firstName=NetCICD \
    -s lastName=Pipeline \
    -s email=netcicd-pipeline@infraautomators.example.com

./kcadm.sh set-password -r netcicd --username netcicd-pipeline --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername netcicd-pipeline --cclientid Nexus --rolename nexus-apk-read


./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=thedude \
    -s firstName=The \
    -s lastName=Dude \
    -s email=thedude@infraautomators.example.com &>NetCICD_THEDUDE
dude_id=$(cat NetCICD_THEDUDE | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username thedude --new-password thedude

./kcadm.sh update users/$dude_id/groups/$camops_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$dude_id \
    -s groupId=$camops_id \
    -n

./kcadm.sh update users/$dude_id/groups/$wanops_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$dude_id \
    -s groupId=$wanops_id \
    -n

./kcadm.sh update users/$dude_id/groups/$dcops_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$dude_id \
    -s groupId=$dcops_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=thespecialist \
    -s firstName=The \
    -s lastName=Specialist \
    -s email=boom@infraautomators.example.com &>NetCICD_THESPEC

spec_id=$(cat NetCICD_THESPEC | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username thespecialist --new-password thespecialist

./kcadm.sh update users/$spec_id/groups/$camspec_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$spec_id \
    -s groupId=$camspec_id \
    -n

./kcadm.sh update users/$spec_id/groups/$wanspec_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$spec_id \
    -s groupId=$wanspec_id \
    -n

./kcadm.sh update users/$spec_id/groups/$dcspec_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$spec_id \
    -s groupId=$dcspec_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=architect \
    -s firstName=The \
    -s lastName=Architect \
    -s email=architect@infraautomators.example.com &>NetCICD_ARCH

arch_id=$(cat NetCICD_ARCH | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username architect --new-password architect

./kcadm.sh update users/$arch_id/groups/$storarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$storarch_id \
    -n

./kcadm.sh update users/$arch_id/groups/$ctarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$ctarch_id \
    -n

./kcadm.sh update users/$arch_id/groups/$vmarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$vmarch_id \
    -n

./kcadm.sh update users/$arch_id/groups/$clarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$clarch_id \
    -n

./kcadm.sh update users/$arch_id/groups/$camarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$camarch_id \
    -n

./kcadm.sh update users/$arch_id/groups/$wanarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$wanarch_id \
    -n

./kcadm.sh update users/$arch_id/groups/$dcarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$arch_id \
    -s groupId=$dcarch_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=hacker \
    -s firstName=Happy \
    -s lastName=Hacker \
    -s email=whitehat@infraautomators.example.com &>NetCICD_HACKER

hack_id=$(cat NetCICD_HACKER | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username hacker --new-password whitehat

./kcadm.sh update users/$hack_id/groups/$toolops_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$hack_id \
    -s groupId=$toolops_id \
    -n

./kcadm.sh update users/$hack_id/groups/$tooldev_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$hack_id \
    -s groupId=$tooldev_id \
    -n

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=tooltiger \
    -s firstName=Tool \
    -s lastName=Tiger \
    -s email=tooltiger@infraautomators.example.com &>NetCICD_TOOLTIGER

tooltiger_id=$(cat NetCICD_TOOLTIGER | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username tooltiger --new-password tooltiger

./kcadm.sh update users/$tooltiger_id/groups/$toolarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$tooltiger_id \
    -s groupId=$toolarch_id \
    -n

#Now delete tokens and secrets
#rm NetCICD_*
