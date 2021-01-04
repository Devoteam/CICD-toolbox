#!/bin/bash 
# shell script to be copied into /opt/jboss/keycloak/bin
cd /opt/jboss/keycloak/bin
#Create credentials
./kcadm.sh config credentials --server http://keycloak:8080/auth --realm master --user admin --password Pa55w0rd

#add realm
./kcadm.sh create realms -s realm=netcicd -s enabled=true 

#add clients
./kcadm.sh create clients \
    -r netcicd \
    -s name="Gitea" \
    -s description="The Gitea git server in the toolchain" \
    -s clientId=Gitea \
    -s enabled=true \
    -s bearerOnly=false \
    -s publicClient=false \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://gitea:3000 \
    -s adminUrl=http://gitea:3000/ \
    -s 'redirectUris=[ "http://gitea:3000/user/oauth2/keycloak/callback" ]' \
    -s 'webOrigins=[ "http://gitea:3000/" ]' \
    -o --fields id >GITEA

# output is Created new client with id, we now need to grep the ID out of it
GITEA_ID=$(cat GITEA | grep id | cut -d'"' -f 4)
#echo $GITEA_ID

# We need to retrieve the token from keycloak for this client
./kcadm.sh get clients/$GITEA_ID/client-secret -r netcicd >gitea_secret
GITEA_token=$(grep value gitea_secret | cut -d '"' -f4)
# Make sure we can grep the clienttoken easily from the keycloak_create.log to create an authentication source in Gitea for Keycloak
echo "GITEA_token: " $GITEA_token

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-infraautomators-admin -s description='The admin role for the Infra Automators organization'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netops-read -s description='A read-only role for network operations, intended for users/operators'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netops-write -s description='A read-write role for network operations, intended for network specialists'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netdev-read -s description='A read-only role for network development, intended for network architects'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netdev-write -s description='A read-write role for network development, intended for network senior network architects'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-tooling-read -s description='A read-only role for the tooling team, intended for developers that do not alter platform specific workflows'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-tooling-write -s description='A read-write role for the tooling team, intended for senior developers of the tooling team'

#Now delete tokens and secrets
rm GITEA
rm gitea_secret
GITEA_ID=""
GITEA_token=""

./kcadm.sh create clients \
    -r netcicd \
    -s name="Jenkins" \
    -s description="The Jenkins orchestrator in the toolchain" \
    -s clientId=Jenkins \
    -s enabled=true \
    -s publicClient=true \
    -s fullScopeAllowed=false \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://jenkins:8080 \
    -s adminUrl=http://jenkins:8080/ \
    -s 'redirectUris=[ "http://jenkins:8080/*" ]' \
    -s 'webOrigins=[ "http://jenkins:8080/" ]' \
    -o --fields id >JENKINS

# output is Created new client with id, we now need to grep the ID out of it
JENKINS_ID=$(cat JENKINS | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-admin -s description='The admin role for Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-user -s description='A user in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-agent -s description='The role to be used for a user that needs to create agents in Jenkins'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-run -s description='The role to be used for a user that needs to run the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-dev -s description='The role to be used for a user that needs to configure the NetCICD pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-toolbox-run -s description='The role to be used for a user that needs to run the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-toolbox-dev -s description='The role to be used for a user that needs to configure the NetCICD-developer-toolbox pipeline'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-gitea -s description='The role to be used for a user that needs to retrieve a repo from Gitea'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-nexus -s description='The role to be used for Jenkins to push data to Nexus'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-argos -s description='The role to be used for Jenkins to log keys to Argos'
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-cml -s description='The role to be used for Jenkins to interact with Cisco Modeling Labs (CML)'
   
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
    -s rootUrl=http://nexus:8080 \
    -s adminUrl=http://nexus:8080/ \
    -s 'redirectUris=[ "http://nexus:8080/*" ]' \
    -s 'webOrigins=[ "http://nexus:8080/" ]' \
    -o --fields id >NEXUS

# output is Created new client with id, we now need to grep the ID out of it
NEXUS_ID=$(cat NEXUS | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-admin -s description='The admin role for Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-netcicd-agent -s description='The role to be used for a Jenkins agent to push data to Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-docker-pull -s description='The role to be used in order to pull from the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-docker-push -s description='The role to be used in order to push to the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-read -s description='The role to be used for a Jenkins agent to push data to Nexus'
# Now add the service account for Nexus
./kcadm.sh add-roles -r netcicd --uusername service-account-nexus --cclientid realm-management --rolename view-clients --rolename view-realm --rolename view-users

#download Nexus OIDC file
./kcadm.sh get clients/$NEXUS_ID/installation/providers/keycloak-oidc-keycloak-json -r netcicd > keycloak-nexus.json

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
    -o --fields id >RADIUS

# output is Created new client with id, we now need to grep the ID out of it
RADIUS_ID=$(cat RADIUS | grep id | cut -d'"' -f 4)

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
    -o --fields id >TACACS

# output is Created new client with id, we now need to grep the ID out of it
TACACS_ID=$(cat TACACS | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$TACACS_ID/roles -r netcicd -s name=TACACS-admin -s description='The admin role for FreeRADIUS'
./kcadm.sh create clients/$TACACS_ID/roles -r netcicd -s name=TACACS-network-admin -s description='An admin role to be used for RADIUS based AAA on Cisco routers, priv 15'
./kcadm.sh create clients/$TACACS_ID/roles -r netcicd -s name=TACACS-network-operator -s description='A role to be used for RADIUS based AAA on Cisco routers, priv 2'

#add groups - we start at the ICT infra level, which implements the capacity layer of the MyREFerence model
./kcadm.sh create groups -r netcicd -s name="Infra" &>INFRA
infra_id=$(cat INFRA | grep id | cut -d"'" -f 2)
echo "Created Infra Department with ID: ${infra_id}" 
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Operations" &>OPS
ops_id=$(cat OPS | grep id | cut -d"'" -f 2)
echo "Created Operations Department with ID: ${ops_id}" 
echo " "

./kcadm.sh create groups/$ops_id/children -r netcicd -s name="Field Services" &>FS
field_services_id=$(cat FS | grep id | cut -d"'" -f 2)
echo "Created Field Services Department with ID: ${field_services_id}" 

./kcadm.sh create groups/$field_services_id/children -r netcicd -s name="Field Service Engineers" &>FSE
fse_id=$(cat FSE | grep id | cut -d"'" -f 2)
echo "Created Field Service Engineers group within the Field Services Department with ID: ${fse_id}" 
echo " "

./kcadm.sh create groups/$ops_id/children -r netcicd -s name="Network" &>NET
network_id=$(cat NET | grep id | cut -d"'" -f 2)
echo "Created Network Department with ID: ${network_id}" 

./kcadm.sh create groups/$network_id/children -r netcicd -s name="Campus" &>CAMPUS
campus_id=$(cat CAMPUS | grep id | cut -d"'" -f 2)
echo "Created Campus Network Department within the Network Department with ID: ${campus_id}" 

./kcadm.sh create groups/$campus_id/children -r netcicd -s name="Campus-operators" &>CAMOPS
camops_id=$(cat CAMOPS | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to Campus Operators."
echo " "

./kcadm.sh create groups/$campus_id/children -r netcicd -s name="Campus-specialist" &>CAMSPEC
camspec_id=$(cat CAMSPEC | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to Operations Campus Specialists."
echo " "

./kcadm.sh create groups/$network_id/children -r netcicd -s name="WAN" &>WAN
wan_id=$(cat WAN | grep id | cut -d"'" -f 2)
echo "Created WAN Network Department within the Network Department with ID: ${wan_id}" 

./kcadm.sh create groups/$wan_id/children -r netcicd -s name="WAN-operators" &>WANOPS
wanops_id=$(cat WANOPS | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to WAN Operators."
echo " "

./kcadm.sh create groups/$wan_id/children -r netcicd -s name="WAN-specialist" &>WANSPEC
wanspec_id=$(cat WANSPEC | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to Operations WAN Specialists."
echo " "

./kcadm.sh create groups/$network_id/children -r netcicd -s name="Datacenter" &>DC
dc_id=$(cat DC | grep id | cut -d"'" -f 2)
echo "Created DC Network Department within the Network Department with ID: ${dc_id}" 

./kcadm.sh create groups/$dc_id/children -r netcicd -s name="DC-operators" &>DCOPS
dcops_id=$(cat DCOPS | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to DC Operators."
echo " "

./kcadm.sh create groups/$dc_id/children -r netcicd -s name="DC-specialist" &>DCSPEC
dcspec_id=$(cat DCSPEC | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to Operations DC Specialists."
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Compute" &>COMPUTE
compute_id=$(cat COMPUTE | grep id | cut -d"'" -f 2)
echo "Created Compute Department with ID: ${compute_id}" 

./kcadm.sh create groups/$compute_id/children -r netcicd -s name="Container" &>CONTAINER
container_id=$(cat CONTAINER | grep id | cut -d"'" -f 2)
echo "Created Container Department within the Compute Department with ID: ${container_id}" 

./kcadm.sh create groups/$container_id/children -r netcicd -s name="Container operators" &>CTOPS
ctops_id=$(cat CTOPS | grep id | cut -d"'" -f 2)
echo "Created Container Operator group within the Container group with ID: ${ctops_id}" 

./kcadm.sh create groups/$container_id/children -r netcicd -s name="Container-specialist" &>CTSPEC
ctspec_id=$(cat CTSPEC | grep id | cut -d"'" -f 2)
echo "Created Container specialist group within the Container group with ID: ${ctspec_id}" 
echo " "

./kcadm.sh create groups/$compute_id/children -r netcicd -s name="VM" &>VM
vm_id=$(cat VM | grep id | cut -d"'" -f 2)
echo "Created VM Department within the Compute Department with ID: ${vm_id}" 

./kcadm.sh create groups/$vm_id/children -r netcicd -s name="VM-operators" &>VMOPS
vmops_id=$(cat VMOPS | grep id | cut -d"'" -f 2)
echo "Created VM Operator group within the VM group with ID: ${vmops_id}" 

./kcadm.sh create groups/$vm_id/children -r netcicd -s name="VM-specialist" &>VMSPEC
vmspec_id=$(cat VMSPEC | grep id | cut -d"'" -f 2)
echo "Created VM Specialist group within the VM group with ID: ${vmspec_id}" 
echo " "

./kcadm.sh create groups/$compute_id/children -r netcicd -s name="Cloud" &>CL
cl_id=$(cat CL | grep id | cut -d"'" -f 2)
echo "Created Cloud Department within the Compute Department with ID: ${cl_id}" 

./kcadm.sh create groups/$cl_id/children -r netcicd -s name="Cloud-operators" &>CLOPS
clops_id=$(cat CLOPS | grep id | cut -d"'" -f 2)
echo "Created Cloud Operators group within the Cloud group with ID: ${clops_id}" 

./kcadm.sh create groups/$cl_id/children -r netcicd -s name="Cloud-specialist" &>CLSPEC
clspec_id=$(cat CLSPEC | grep id | cut -d"'" -f 2)
echo "Created Cloud Specialist group within the Cloud group with ID: ${clspec_id}" 
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Storage" &>STORAGE
storage_id=$(cat STORAGE | grep id | cut -d"'" -f 2)
echo "Created Storage Department with ID: ${storage_id}" 
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Development" &>DEV
dev_id=$(cat DEV | grep id | cut -d"'" -f 2)
echo "Created Development Department with ID: ${dev_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Campus-architect" &>CAMARCH
camarch_id=$(cat CAMARCH | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to Campus Architects."
echo " "

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="WAN-architect" &>WANARCH
wanarch_id=$(cat WANARCH | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to WAN Architects."
echo " "

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="DC-architect" &>DCARCH
dcarch_id=$(cat DCARCH | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-dev \
    --rolename jenkins-netcicd-toolbox-run 
echo "Added roles to DC Architects."
echo " "

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Storage-architect" &>STORARCH
storarch_id=$(cat STORARCH | grep id | cut -d"'" -f 2)
echo "Created Storage Architect group within the Development Department with ID: ${storarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Container-architect" &>CONTARCH
ctarch_id=$(cat CONTARCH | grep id | cut -d"'" -f 2)
echo "Created Container Architect group within the Development Department with ID: ${ctarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="VM Architect" &>VMARCH
vmarch_id=$(cat VMARCH | grep id | cut -d"'" -f 2)
echo "Created VM Architect group within the Development Department with ID: ${vmarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Cloud Architect" &>CLARCH
clarch_id=$(cat CLARCH | grep id | cut -d"'" -f 2)
echo "Created Cloud Architect group within the Development Department with ID: ${clarch_id}" 

./kcadm.sh create groups/$dev_id/children -r netcicd -s name="Tooling Architect" &>TOOLARCH
toolarch_id=$(cat TOOLARCH | grep id | cut -d"'" -f 2)
echo "Created Tooling Architect group within the Development Department with ID: ${toolarch_id}" 

#adding client roles to the group
./kcadm.sh add-roles \
    -r netcicd \
    --gid $tooldev_id \
    --cclientid Jenkins \
    --rolename jenkins-netcicd-toolbox-dev 
echo "Added roles to Tooling Architect."
echo " "

./kcadm.sh create groups/$infra_id/children -r netcicd -s name="Tooling" &>TOOL
tool_id=$(cat TOOL | grep id | cut -d"'" -f 2)
echo "Created Tooling Department with ID: ${tool_id}" 

./kcadm.sh create groups/$tool_id/children -r netcicd -s name="Tooling Operations" &>TOOLOPS
toolops_id=$(cat TOOLOPS | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-run 

./kcadm.sh create groups/$tool_id/children -r netcicd -s name="Tooling Development" &>TOOLDEV
tooldev_id=$(cat TOOLDEV | grep id | cut -d"'" -f 2)
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
    --rolename jenkins-netcicd-run \
    --rolename jenkins-netcicd-toolbox-dev 

#add users
./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=netcicd \
    -s firstName=network \
    -s lastName=CICD \
    -s email=netcicd@infraautomators.example.com
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
    -s firstName=network \
    -s lastName=Operator \
    -s email=git-jenkins@infraautomators.example.com
./kcadm.sh set-password -r netcicd --username git-jenkins --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Gitea --rolename gitea-netops-write
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Jenkins --rolename jenkins-gitea

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=thedude \
    -s firstName=The \
    -s lastName=Dude \
    -s email=thedude@infraautomators.example.com &>THEDUDE
dude_id=$(cat THEDUDE | grep id | cut -d"'" -f 2)

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
    -s email=boom@infraautomators.example.com &>THESPEC

spec_id=$(cat THESPEC | grep id | cut -d"'" -f 2)

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
    -s email=architect@infraautomators.example.com &>ARCH

arch_id=$(cat ARCH | grep id | cut -d"'" -f 2)

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

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=hacker \
    -s firstName=Happy \
    -s lastName=Hacker \
    -s email=whitehat@infraautomators.example.com &>HACKER

hack_id=$(cat HACKER | grep id | cut -d"'" -f 2)

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
    -s email=tooltiger@infraautomators.example.com &>TOOLTIGER

tooltiger_id=$(cat TOOLTIGER | grep id | cut -d"'" -f 2)

./kcadm.sh set-password -r netcicd --username tooltiger --new-password tooltiger

./kcadm.sh update users/$tooltiger_id/groups/$toolarch_id \
    -r netcicd \
    -s realm=netcicd \
    -s userId=$tooltiger_id \
    -s groupId=$toolarch_id \
    -n
