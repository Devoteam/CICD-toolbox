#!/bin/bash 
# shell script to be copied into /opt/jboss/keycloak/bin
cd /opt/jboss/keycloak/bin
#Create credentials
./kcadm.sh config credentials --server http://172.16.11.11:8080/auth --realm master --user admin --password Pa55w0rd

#add realm
./kcadm.sh create realms -s realm=netcicd -s enabled=true 

#Add global roles (specific for RADIUS testing)
./kcadm.sh create roles \
    -r netcicd \
    -s name="ACCEPT_ROLE" \
    -s description="RADIUS accepted users" \
    -s 'attributes={ "ACCEPT_NAS-IP-Address": [ "192.168.88.1" ]}'

./kcadm.sh create roles \
    -r netcicd \
    -s name="REJECT_ROLE" \
    -s description="RADIUS rejected users" \
    -s 'attributes={ "REJECT_NAS-IP-Address": [ "192.168.88.1" ] }'

#add clients
./kcadm.sh create clients \
    -r netcicd \
    -s name="Gitea" \
    -s description="The Gitea git server in the toolchain" \
    -s clientId=Gitea \
    -s enabled=true \
    -s bearerOnly=false \
    -s publicClient=false \
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
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-admin -s description='The admin role for the NetCICD repo'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-write -s description='The admin role for the NetCICD repo'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-read -s description='The admin role for the NetCICD repo'

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
./kcadm.sh create clients/$JENKINS_ID/roles -r netcicd -s name=jenkins-netcicd-agent -s description='The role to be used for a user that needs to create agents in Jenkins'
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
    -s publicClient=true \
    -s directAccessGrantsEnabled=true \
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

#add users
./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=netcicd \
    -s firstName=network \
    -s lastName=CICD \
    -s email=netcicd@example.com
./kcadm.sh set-password -r netcicd --username netcicd --new-password netcicd
./kcadm.sh add-roles -r netcicd --uusername netcicd --cclientid Gitea --rolename gitea-netcicd-admin
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
    -s email=netcicd@b.c
./kcadm.sh set-password -r netcicd --username git-jenkins --new-password netcicd
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Gitea --rolename gitea-netcicd-read
./kcadm.sh add-roles -r netcicd  --uusername git-jenkins --cclientid Jenkins --rolename jenkins-gitea

./kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=guest \
    -s firstName=network \
    -s lastName=Operator \
    -s email=guest@b.c
./kcadm.sh set-password -r netcicd --username guest --new-password guest
./kcadm.sh add-roles -r netcicd --uusername guest --cclientid Jenkins --rolename jenkins-cml