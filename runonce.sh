#!/bin/bash 
echo "**********************************************************************"
echo " Start clean" 
echo "**********************************************************************"
docker-compose down --remove-orphans
rm *_token
rm keycloak_create.log
echo " " 
echo "**********************************************************************"
echo " Cleaning Databases" 
echo "**********************************************************************"
sudo chown $USER:$USER netcicd-db/db
sudo rm -rf netcicd-db/db/*
echo " " 
echo "**********************************************************************"
echo " Cleaning Gitea" 
echo "**********************************************************************"
sudo rm -rf gitea/data/*
echo " " 
echo "**********************************************************************"
echo " Cleaning Jenkins" 
echo "**********************************************************************"
sudo rm -rf jenkins/jenkins_home/*
sudo rm -rf jenkins/jenkins_home/.*
echo " " 
echo "**********************************************************************"
echo " Cleaning Nexus" 
echo "**********************************************************************"
sudo rm -rf nexus/data/*
echo " " 
echo "**********************************************************************"
echo " Cleaning Argos" 
echo "**********************************************************************"
sudo rm -rf argos/config/*
sudo rm -rf argos/data/*
echo " " 
echo "**********************************************************************"
echo " Cleaning FreeIPA" 
echo "**********************************************************************"
sudo rm -rf freeipa/data/*
sudo rm -rf freeipa/data/.*
echo " " 
echo "**********************************************************************"
echo " Cleaning NodeRED" 
echo "**********************************************************************"
sudo chown $USER:$USER nodered/data
sudo rm -rf nodered/data/*
echo " " 
echo "**********************************************************************"
echo " Cleaning Jupyter Notebook" 
echo "**********************************************************************"
sudo chown $USER:$USER jupyter/data
sudo rm -rf jupyter/data/*
echo " " 
echo "**********************************************************************"
echo " Cleaning Portainer" 
echo "**********************************************************************"
sudo chown $USER:$USER portainer/data
sudo rm -rf portainer/data/*
echo " " 
echo "**********************************************************************"
echo " Creating containers"
echo "**********************************************************************"
docker-compose up -d --build
echo " " 
echo "**********************************************************************"
echo " Use docker-compose up -d next time"
echo "**********************************************************************"
echo " " 
echo "**********************************************************************"
echo " Wait until keycloak is running"
echo "**********************************************************************"
until $(curl --output /dev/null --silent --head --fail http://172.16.11.11:8080); do
    printf '.'
    sleep 5
done
echo " "
echo "**********************************************************************"
echo " Creating keycloak setup"
echo "**********************************************************************"
docker exec -it keycloak sh -c "/opt/jboss/keycloak/bin/create-realm.sh"  > keycloak_create.log
echo " " 
cat keycloak_create.log
echo " " 
echo "**********************************************************************"
echo " Wait until gitea is running"
until $(curl --output /dev/null --silent --head --fail http://172.16.11.3:3000); do
    printf '.'
    sleep 5
done
echo "**********************************************************************"
echo " Now go to http://172.16.11.3:3000 and"
echo " "
echo " Press install... you may need to " 
echo " "
echo " login to see install" 
echo " "
echo "**********************************************************************"
read -p " Press any key to continue... " -n1 -s
echo " "
echo "**********************************************************************"
echo " Configuring Gitea"
echo "**********************************************************************"
echo " " 
echo "**********************************************************************"
echo " Create gitusers"
echo "**********************************************************************"
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username netcicd --password netcicd --admin --email networkautomation@devoteam.nl --access-token'" > netcicd_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username git-jenkins --password netcicd --email git-jenkins@netcicd.nl --access-token --must-change-password=false'" > git_jenkins_token 

token0=`cat netcicd_token  | awk '/Access token was successfully created... /{print $NF}' netcicd_token `
echo "netcicd_token  is: " $token0

token2=`cat git_jenkins_token | awk '/Access token was successfully created... /{print $NF}' git_jenkins_token`
echo "git_jenkins_token is: " $token2
echo " "
echo "**********************************************************************"
echo " Creating repo in Gitea "
echo "**********************************************************************"
curl --user netcicd:netcicd -X POST "http://172.16.11.3:3000/api/v1/repos/migrate" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"auth_password\": \"string\",  \"auth_token\": \"string\",  \"auth_username\": \"string\",  \"clone_addr\": \"https://github.com/Devoteam/NetCICD.git\",  \"description\": \"string\",  \"issues\": true,  \"labels\": true,  \"milestones\": true,  \"mirror\": false,  \"private\": true,  \"pull_requests\": true,  \"releases\": true,  \"repo_name\": \"NetCICD\",  \"repo_owner\": \"netcicd\",  \"service\": \"git\",  \"uid\": 0,  \"wiki\": true}"
echo " "
echo "**********************************************************************"
echo " Create Develop branch "
echo "**********************************************************************"
curl -X POST "http://172.16.11.3:3000/api/v1/repos/netcicd/NetCICD/branches" --user netcicd:netcicd -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"new_branch_name\": \"develop\"}"
echo " "
echo "**********************************************************************"
echo " Add git-jenkins user to repo "
curl -X PUT "http://172.16.11.3:3000/api/v1/repos/netcicd/NetCICD/collaborators/git-jenkins" --user netcicd:netcicd -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"permission\": \"write\"}"
echo " Adding keycloak client key to Gitea"
echo "**********************************************************************"
gitea_client_id=$(grep GITEA_token keycloak_create.log | cut -d' ' -f3)
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin auth add-oauth --name keycloak --provider openidConnect --key Gitea --secret $gitea_client_id --auto-discover-url http://172.16.11.11:8080/auth/realms/netcicd/.well-known/openid-configuration --config=/data/gitea/conf/app.ini'"
echo "**********************************************************************"
echo " You'll need to confirm the keycloak settings in Gitea"
echo " Site administration->Authentication Sources->keycloak->update"
echo "**********************************************************************"
echo "NetCICD Toolkit install done "
echo " "
echo "You can reach the servers on:"
echo " "
echo " Gitea:       http://172.16.11.3:3000"
echo " Jenkins:     http://172.16.11.8:8080"
echo " Nexus:       http://172.16.11.9:8081"
echo " Argos:       http://172.16.11.10"
echo " Keycloak:    http://172.16.11.11:8443"
echo " Node-red:    http://172.16.11.13:1880"
echo " Jupyter:     http://172.16.11.14:8888"
echo " Portainer:   http://172.16.11.15:9000"
echo " "
echo " There is one last step to take,"
echo " which is setting the JENKINS-SIM"
echo " credentials. The user netcicd needs"
echo " a token and that token is the"
echo " password for JENKINS-SIM"
echo " "
echo "**********************************************************************"
