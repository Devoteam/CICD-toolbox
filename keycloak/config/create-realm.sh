# shell script to be copied into /opt/jboss/keycloak/bin

#Create credentials
kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password Pa55w0rd

#add realm
kcadm.sh create realms -s realm=netcicd -s enabled=true

#add clients
kcadm.sh create clients \
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
    -s 'webOrigins=[ "http://172.16.11.3:3000/" ]'
kcadm.sh create clients \
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
    -s 'webOrigins=[ "http://172.16.11.8:8080/" ]'
kcadm.sh create clients \
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
    -s 'webOrigins=[ "http://172.16.11.9:8080/" ]'

#add roles
kcadm.sh create roles -r netcicd -s name=jenkins_admin -s 'description=User with Jenkins admin permissions'
kcadm.sh create roles -r netcicd -s name=jenkins_readonly -s 'description=User with Jenkins only read permissions'

#add users
kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=networkoperator \
    -s firstName=network \
    -s lastName=Operator \
    -s email=operator@b.c
kcadm.sh set-password -r netcicd --username networkoperator --new-password netcicd
kcadm.sh add-roles --uusername networkoperator --rolename jenkins_readonly -r demorealm

kcadm.sh create users \
    -r netcicd \
    -s enabled=true \
    -s username=networkadmin \
    -s firstName=network \
    -s lastName=Admin \
    -s email=admin@b.c
kcadm.sh set-password -r netcicd --username networkadmin --new-password netcicd
kcadm.sh add-roles --uusername networkadmin --rolename jenkins_admin -r demorealm