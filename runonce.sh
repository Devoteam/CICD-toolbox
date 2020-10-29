#!/bin/bash 
echo "***********************************"
echo "Start clean" 
echo "***********************************"
docker-compose down --remove-orphans
rm *_token
rm keycloak_create.log
echo " " 
echo "***********************************"
echo " Cleaning Argos" 
echo "***********************************"
sudo rm -rf argos/config/*
sudo rm -rf argos/data/*
echo " " 
echo "***********************************"
echo " Cleaning Gitea" 
echo "***********************************"
sudo rm -rf gitea/data/*
echo " " 
echo "***********************************"
echo " Cleaning Jenkins" 
echo "***********************************"
sudo rm -rf jenkins/jenkins_home/*
sudo rm -rf jenkins/jenkins_home/.*
echo " " 
echo "***********************************"
echo " Cleaning Nexus" 
echo "***********************************"
sudo rm -rf nexus/data/*
echo " " 
echo "***********************************"
echo " Cleaning Databases" 
echo "***********************************"
sudo chown $USER:$USER netcicd-db/db
sudo rm -rf netcicd-db/db/*
echo " " 
echo "***********************************"
echo "Creating containers"
echo "***********************************"
docker-compose up -d --build
echo " " 
echo "***********************************"
echo "Use docker-compose up -d next time"
echo "***********************************"
echo " " 
#First step is to see if keycloak is running.


echo "***********************************"
echo "Now go to http://172.16.11.3:3000 and"
echo " "
echo "Press install... you may need to " 
echo " "
echo " login to see install" 
echo " "
echo "***********************************"
read -p "Press any key to continue... " -n1 -s
echo " " 
echo "**********************************"
echo "Create gitusers"
echo "**********************************"
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username netcicd --password netcicd --admin --email networkautomationdocker@devoteam.nl --access-token'" > netcicd_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username $USER --password $USER --admin --email netcicd@netcicd.nl --access-token --must-change-password=false'" > ${USER}_token 
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username git-jenkins --password netcicd --email git-jenkins@netcicd.nl --access-token --must-change-password=false'" > git_jenkins_token 

token0=`cat ${USER}_token  | awk '/Access token was successfully created... /{print $NF}' netcicd_token `
echo "netcicd_token  is: " $token0

token1=`cat ${USER}_token  | awk '/Access token was successfully created... /{print $NF}' ${USER}_token `
echo "${USER}_token  is: " $token1

token2=`cat git_jenkins_token | awk '/Access token was successfully created... /{print $NF}' git_jenkins_token`
echo "git_jenkins_token is: " $token2
echo " "
echo "***********************************"
echo " Creating repo in Gitea "
echo "***********************************"
echo " "
curl --user netcicd:netcicd -X POST "http://172.16.11.3:3000/api/v1/repos/migrate" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"auth_password\": \"string\",  \"auth_token\": \"string\",  \"auth_username\": \"string\",  \"clone_addr\": \"https://github.com/Devoteam/NetCICD.git\",  \"description\": \"string\",  \"issues\": true,  \"labels\": true,  \"milestones\": true,  \"mirror\": true,  \"private\": true,  \"pull_requests\": true,  \"releases\": true,  \"repo_name\": \"NetCICD\",  \"repo_owner\": \"netcicd\",  \"service\": \"git\",  \"uid\": 0,  \"wiki\": true}"
echo " "
echo "***********************************"
echo "Create Develop branch "
echo "***********************************"
curl -X POST "http://172.16.11.3:3000/api/v1/repos/netcicd/NetCICD/branches" --user $USER:$USER -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"new_branch_name\": \"develop\"}"
echo " "
echo "***********************************"
echo "Add $USER user to repo "
echo "***********************************"
curl -X PUT "http://172.16.11.3:3000/api/v1/repos/netcicd/NetCICD/collaborators/${USER}" --user netcicd:netcicd -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"permission\": \"write\"}"
echo " "
echo "***********************************"
echo "Add git-jenkins user to repo "
echo "***********************************"
curl -X PUT "http://172.16.11.3:3000/api/v1/repos/netcicd/NetCICD/collaborators/git-jenkins" --user netcicd:netcicd -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"permission\": \"write\"}"
echo "***********************************"
echo "Now go to http://172.16.11.11:8443 and"
echo " "
echo " Check if keycloak is running"
echo " "
echo "***********************************"
read -p "Press any key to continue... " -n1 -s
echo " " 
echo "***********************************"
echo " Creating keycloak setup"
echo "***********************************"
docker exec -it keycloak sh -c "/opt/jboss/keycloak/bin/create-realm.sh"  > keycloak_create.log
cat keycloak_create.log
echo " "
echo "***********************************"
echo "NetCICD Toolkit install done "
echo " "
echo "You can reach the servers on:"
echo " "
echo " Gitea:       http://172.16.11.3:3000"
echo " Jenkins:     http://172.16.11.8:8080"
echo " Nexus:       http://172.16.11.9:8081"
echo " Argos:       http://172.16.11.10"
echo " "
echo "In case you want to have the services"
echo "local to your laptop, uncomment the "
echo "port settings in the"
echo "docker-compose file."
echo " "
echo "***********************************"
