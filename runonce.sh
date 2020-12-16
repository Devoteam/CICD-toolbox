#!/bin/bash 

user=Devoteam
pwd=netcicd
nexus_plugin="0.4.0"

echo "****************************************************************************************************************"
echo " Start clean" 
echo "****************************************************************************************************************"
docker-compose down --remove-orphans
rm *_token
rm keycloak_create.log
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning Databases" 
echo "****************************************************************************************************************"
sudo chown $USER:$USER netcicd-db/db
sudo rm -rf netcicd-db/db/*
sudo rm -rf netcicd-db/db/.*
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning Gitea" 
echo "****************************************************************************************************************"
sudo rm -rf gitea/data/*
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning Jenkins" 
echo "****************************************************************************************************************"
sudo rm -rf jenkins/jenkins_home/*
sudo rm -rf jenkins/jenkins_home/.*
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning Nexus" 
echo "****************************************************************************************************************"
sudo rm -rf nexus/data/*
echo " " 
echo "****************************************************************************************************************"
echo " Collecting Nexus Keycloak plugin jar files" 
echo "****************************************************************************************************************"
if [ -f "nexus/nexus3-keycloak-plugin-$nexus_plugin-bundle.kar" ]; then
    echo " Nexus plugin exists"
else
    echo " Get Nexus plugin"
    wget --directory-prefix=nexus https://github.com/flytreeleft/nexus3-keycloak-plugin/releases/download/v$nexus_plugin/nexus3-keycloak-plugin-$nexus_plugin-bundle.kar
fi
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning Argos" 
echo "****************************************************************************************************************"
sudo rm -rf argos/config/*
sudo rm -rf argos/data/*
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning NodeRED" 
echo "****************************************************************************************************************"
sudo chown $USER:$USER nodered/data
sudo rm -rf nodered/data/*
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning Jupyter Notebook" 
echo "****************************************************************************************************************"
sudo chown $USER:$USER jupyter/data
sudo rm -rf jupyter/data/*
echo " " 
echo "****************************************************************************************************************"
echo " Cleaning Portainer" 
echo "****************************************************************************************************************"
sudo chown $USER:$USER portainer/data
sudo rm -rf portainer/data/*
echo " " 
echo "****************************************************************************************************************"
echo " Make sure all containers are reachable locally with the name in the"
echo " hosts file."
echo " " 
sudo chmod o+w /etc/hosts
if grep -q "gitea" /etc/hosts; then
    echo " Gitea exists in /etc/hosts"
else
    echo " Add Gitea to /etc/hosts"
    sudo echo "172.16.11.3   gitea" >> /etc/hosts
fi

if grep -q "jenkins" /etc/hosts; then
    echo " Jenkins exists in /etc/hosts"
else
    echo " Add Jenkins to /etc/hosts"
    sudo echo "172.16.11.8   jenkins" >> /etc/hosts
fi

if grep -q "nexus" /etc/hosts; then
    echo " Nexus exists in /etc/hosts"
else
    echo " Add Nexus to /etc/hosts"
    sudo echo "172.16.11.9   nexus" >> /etc/hosts
fi

if grep -q "argos" /etc/hosts; then
    echo " Argos exists in /etc/hosts"
else
    echo " Add Argos to /etc/hosts"
    sudo echo "172.16.11.10   argos" >> /etc/hosts
fi

if grep -q "keycloak" /etc/hosts; then
    echo " Keycloak exists in /etc/hosts"
else
    echo " Add Keycloak to /etc/hosts"
    sudo echo "172.16.11.11   keycloak" >> /etc/hosts
fi

if grep -q "nodered" /etc/hosts; then
    echo " Node Red exists in /etc/hosts"
else
    echo " Add Node Red to /etc/hosts"
    sudo echo "172.16.11.13   nodered" >> /etc/hosts
fi

if grep -q "jupyter" /etc/hosts; then
    echo " Jupyter Notebook exists in /etc/hosts"
else
    echo " Add Jupyter to /etc/hosts"
    sudo echo "172.16.11.14   jupyter" >> /etc/hosts
fi

if grep -q "portainer" /etc/hosts; then
    echo " Portainer exists in /etc/hosts"
else
    echo " Add Potainer to /etc/hosts"
    sudo echo "172.16.11.15   portainer" >> /etc/hosts
fi

if grep -q "cml" /etc/hosts; then
    echo " cml exists in /etc/hosts"
else
    echo " Add Cisco Modeling Labs to /etc/hosts"
    sudo echo "172.16.32.148   cml" >> /etc/hosts
fi
sudo chmod o-w /etc/hosts
echo " " 
echo "****************************************************************************************************************"
echo " git clone Nexus CasC plugin and build .kar file"
echo "****************************************************************************************************************"
git clone https://github.com/AdaptiveConsulting/nexus-casc-plugin.git
cd nexus-casc-plugin
mvn package
cp target/*.kar ../nexus/
cd ..
rm -rf nexus-casc-plugin/
echo " " 
echo "****************************************************************************************************************"
echo " Creating containers"
echo "****************************************************************************************************************"
docker-compose up -d --build
echo " " 
echo "****************************************************************************************************************"
echo " Use docker-compose up -d next time"
echo "****************************************************************************************************************"
echo " " 
echo "****************************************************************************************************************"
echo " Wait until keycloak is running"
echo "****************************************************************************************************************"
until $(curl --output /dev/null --silent --head --fail http://keycloak:8080); do
    printf '.'
    sleep 5
done
echo " "
echo "****************************************************************************************************************"
echo " Addiing keycloak RADIUS plugin"
echo "****************************************************************************************************************"
docker exec -it keycloak sh -c "/opt/radius/scripts/keycloak.sh"
echo " " 
docker restart keycloak
echo " " 
echo "****************************************************************************************************************"
echo " Restarted keycloak to activate RADIUS, wait until keycloak is running"
echo "****************************************************************************************************************"
until $(curl --output /dev/null --silent --head --fail http://keycloak:8080); do
    printf '.'
    sleep 5
done
echo " " 
echo "****************************************************************************************************************"
echo " Creating keycloak setup"
echo "****************************************************************************************************************"
docker exec -it keycloak sh -c "/opt/jboss/keycloak/bin/create-realm.sh"  > keycloak_create.log
echo " "
cat keycloak_create.log
echo " " 
echo "****************************************************************************************************************"
echo " Creating nexus setup"
echo "****************************************************************************************************************"
docker cp keycloak:/opt/jboss/keycloak/bin/keycloak-nexus.json nexus/keycloak-nexus.json
docker cp nexus/keycloak-nexus.json nexus:/opt/sonatype/nexus/etc/keycloak.json
docker restart nexus
echo " " 
echo "****************************************************************************************************************"
echo " Restarted nexus to activate Keycloak, wait until Nexus is running"
echo "****************************************************************************************************************"
until $(curl --output /dev/null --silent --head --fail http://nexus:8081); do
    printf '.'
    sleep 5
done
echo " " 
echo "****************************************************************************************************************"
echo " Wait until gitea is running"
until $(curl --output /dev/null --silent --head --fail http://gitea:3000); do
    printf '.'
    sleep 5
done
echo " "
echo "****************************************************************************************************************"
echo " Now go to http://gitea:3000 and"
echo " "
echo " Press install... you may need to " 
echo " "
echo " login to see install" 
echo " "
echo "****************************************************************************************************************"
read -p " Press any key to continue... " -n1 -s
echo " "
echo "****************************************************************************************************************"
echo " Configuring Gitea"
echo "****************************************************************************************************************"
docker cp gitea/app.ini gitea:/data/gitea/conf/app.ini
echo " "
echo "****************************************************************************************************************"
echo " Adding keycloak client key to Gitea"
echo " "
gitea_client_id=$(grep GITEA_token keycloak_create.log | cut -d' ' -f3)
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin auth add-oauth --name keycloak --provider openidConnect --key Gitea --secret $gitea_client_id --auto-discover-url http://keycloak:8080/auth/realms/netcicd/.well-known/openid-configuration --config=/data/gitea/conf/app.ini'"
echo " "
echo " You'll need to confirm the keycloak settings in Gitea"
echo " Site administration->Authentication Sources->keycloak->update"
echo "****************************************************************************************************************"
echo " Restarting Gitea"
echo "****************************************************************************************************************"
docker restart gitea
echo " Wait until gitea is running"
until $(curl --output /dev/null --silent --head --fail http://gitea:3000); do
    printf '.'
    sleep 5
done
echo " "
echo "****************************************************************************************************************"
echo " Create local gituser (admin role)"
user=gitea-user 
echo "****************************************************************************************************************"
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username $user --password $pwd --admin --email networkautomation@devoteam.nl --access-token'" > admin_token
echo " "
echo "****************************************************************************************************************"
echo " Creating NetCICD organization in Gitea "
echo "****************************************************************************************************************"
ORG_PAYLOAD='{ "description": "Infrastructure automation transformation team", "full_name": "Infrastructure Transformakers", "location": "Github", "repo_admin_change_team_access": true, "username": "infra", "visibility": "public", "website": "https://www.devoteam.com"}'
org_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs" -H "accept: application/json" -H "Content-Type: application/json" --data "${ORG_PAYLOAD}"`
#We may need the ID to add users to the org or team.

netops_team_payload='{ "can_create_org_repo": true, "description": "The network operations team", "includes_all_repositories": false, "name": "netops", "permission": "write", "units": ["repo.code","repo.issues","repo.ext_issues","repo.wiki","repo.pulls","repo.releases","repo.ext_wiki"]}'
ops_team_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infra/teams" -H "accept: application/json" -H "Content-Type: application/json" --data "${ops_team_payload}"`
#We may need the ID to add users to the org or team.

netdev_team_payload='{ "can_create_org_repo": true, "description": "The network architecture team", "includes_all_repositories": false, "name": "netdev", "permission": "write", "units": ["repo.code","repo.issues","repo.ext_issues","repo.wiki","repo.pulls","repo.releases","repo.ext_wiki"]}'
ops_team_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infra/teams" -H "accept: application/json" -H "Content-Type: application/json" --data "${ops_team_payload}"`
#We may need the ID to add users to the org or team.

tooling_team_payload='{ "can_create_org_repo": true, "description": "The tooling team", "includes_all_repositories": false, "name": "tooling", "permission": "write", "units": ["repo.code","repo.issues","repo.ext_issues","repo.wiki","repo.pulls","repo.releases","repo.ext_wiki"]}'
ops_team_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infra/teams" -H "accept: application/json" -H "Content-Type: application/json" --data "${ops_team_payload}"`
#We may need the ID to add users to the org or team.

echo " "
echo "****************************************************************************************************************"
echo " Creating repo in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X POST "http://gitea:3000/api/v1/repos/migrate" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"auth_password\": \"string\",  \"auth_token\": \"string\",  \"auth_username\": \"string\",  \"clone_addr\": \"https://github.com/Devoteam/NetCICD.git\",  \"description\": \"The NetCICD toolbox\",  \"issues\": true,  \"labels\": true,  \"milestones\": true,  \"mirror\": false,  \"private\": false,  \"pull_requests\": true,  \"releases\": true,  \"repo_name\": \"NetCICD\",  \"repo_owner\": \"$user\",  \"service\": \"git\",  \"uid\": 0,  \"wiki\": true}"
echo " "
echo "****************************************************************************************************************"
echo " Create Develop branch "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X POST "http://gitea:3000/api/v1/repos/$user/NetCICD/branches" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"new_branch_name\": \"develop\"}"
echo " " 
echo "****************************************************************************************************************"
echo "Saving Keycloak self-signed certificate"
echo "****************************************************************************************************************"
openssl s_client -showcerts -connect keycloak:8443 </dev/null 2>/dev/null|openssl x509 -outform PEM >./jenkins/keystore/keycloak.pem
echo "****************************************************************************************************************"
echo " Copy certificate into Jenkins keystore"
echo "****************************************************************************************************************"
docker cp jenkins:/usr/local/openjdk-8/jre/lib/security/cacerts ./jenkins/keystore/cacerts
chmod +w ./jenkins/keystore/cacerts
keytool -import -alias Keycloak -keystore ./jenkins/keystore/cacerts -file ./jenkins/keystore/keycloak.pem -storepass changeit -noprompt
docker cp ./jenkins/keystore/cacerts jenkins:/usr/local/openjdk-8/jre/lib/security/cacerts
docker restart jenkins
echo " " 
echo "****************************************************************************************************************"
echo "NetCICD Toolkit install done "
echo " "
echo "You can reach the servers on:"
echo " "
echo " Gitea:       http://gitea:3000"
echo " Jenkins:     http://jenkins:8080"
echo " Nexus:       http://nexus:8081"
echo " Argos:       http://argos"
echo " Keycloak:    http://keycloak:8443"
echo " Node-red:    http://nodered:1880"
echo " Jupyter:     http://jupyter:8888"
echo " Portainer:   http://portainer:9000"
echo " "
echo " There is one last step to take,"
echo " which is setting the JENKINS-SIM"
echo " credentials. The user netcicd needs"
echo " a token and that token is the"
echo " password for JENKINS-SIM"
echo " "
echo "****************************************************************************************************************"
