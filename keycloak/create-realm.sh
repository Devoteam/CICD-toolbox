#!/bin/bash 
# shell script to be copied into /opt/jboss/keycloak/bin
cd /opt/jboss/keycloak/bin
#Create credentials
./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password Pa55w0rd

#add realm
./kcadm.sh create realms -s realm=netcicd -s enabled=true

#add clients
./kcadm.sh create clients \
    -r netcicd \
    -s name="Gitea" \
    -s description="The Gitea git server in the toolchain" \
    -s clientId=Gitea \
    -s enabled=true \
    -s publicClient=true \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://172.16.11.3:3000 \
    -s adminUrl=http://172.16.11.3:3000/ \
    -s 'redirectUris=[ "http://172.16.11.3:3000*" ]' \
    -s 'webOrigins=[ "http://172.16.11.3:3000/" ]' \
    -o --fields id >GITEA

# output is Created new client with id 'f294f7f7-da37-47cf-8497-64f76ca8daab', we now need to grep the ID out of it
GITEA_ID=$(cat GITEA | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-admin -s description='The admin role for the NetCICD repo'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-write -s description='The admin role for the NetCICD repo'
./kcadm.sh create clients/$GITEA_ID/roles -r netcicd -s name=gitea-netcicd-read -s description='The admin role for the NetCICD repo'

./kcadm.sh create clients \
    -r netcicd \
    -s name="Jenkins" \
    -s description="The Jenkins orchestrator in the toolchain" \
    -s clientId=Jenkins \
    -s enabled=true \
    -s publicClient=true \
    -s directAccessGrantsEnabled=true \
    -s rootUrl=http://172.16.11.8:8080 \
    -s adminUrl=http://172.16.11.8:8080/ \
    -s 'redirectUris=[ "http://172.16.11.8:8080/*" ]' \
    -s 'webOrigins=[ "http://172.16.11.8:8080/" ]' \
    -o --fields id >JENKINS

# output is Created new client with id 'f294f7f7-da37-47cf-8497-64f76ca8daab', we now need to grep the ID out of it
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
    -s rootUrl=http://172.16.11.9:8080 \
    -s adminUrl=http://172.16.11.9:8080/ \
    -s 'redirectUris=[ "http://172.16.11.9:8080/*" ]' \
    -s 'webOrigins=[ "http://172.16.11.9:8080/" ]' \
    -o --fields id >NEXUS

# output is Created new client with id 'f294f7f7-da37-47cf-8497-64f76ca8daab', we now need to grep the ID out of it
NEXUS_ID=$(cat NEXUS | grep id | cut -d'"' -f 4)

# Now we can add client specific roles (Clientroles)
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-admin -s description='The admin role for Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-netcicd-agent -s description='The role to be used for a Jenkins agent to push data to Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-docker-pull -s description='The role to be used in order to pull from the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-docker-push -s description='The role to be used in order to push to the Docker mirror on Nexus'
./kcadm.sh create clients/$NEXUS_ID/roles -r netcicd -s name=nexus-read -s description='The role to be used for a Jenkins agent to push data to Nexus'

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