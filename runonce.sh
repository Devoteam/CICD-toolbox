#!/bin/bash
echo "***********************************"
echo "Start clean" 
echo "***********************************"
docker-compose down

sudo rm -rf gitea/data/*
sudo rm -rf jenkins/data/*
sudo rm -rf jenkins/data/.*
sudo rm -rf jenkins/config/*
sudo rm -rf jenkins/docker/*
sudo rm -rf jenkins/sock*
sudo rm -rf nexus/data/*
sudo chown $USER:$USER postgres/data
sudo rm -rf postgres/data/*
echo " " 
echo "***********************************"
echo "Create containers"
echo "***********************************"
docker-compose up -d --build
echo " " 
echo "***********************************"
echo "Use docker-compose up -d next time"
echo "***********************************"
echo " " 
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
echo "Create gituser"
echo "**********************************"
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin create-user --username $USER --password $USER --admin --email netcicd@netcicd.nl --access-token --must-change-password=false'" > ${USER}_token 
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin create-user --username git-jenkins --password netcicd --admin --email git-jenkins@netcicd.nl --access-token --must-change-password=false'" > git_jenkins_token 

token1=`cat ${USER}_token  | awk '/Access token was successfully created... /{print $NF}' ${USER}_token `
echo "${USER}_token  is: " $token1

token2=`cat git_jenkins_token | awk '/Access token was successfully created... /{print $NF}' git_jenkins_token`
echo "git_jenkins_token is: " $token2
echo " "
echo "***********************************"

if [ ! -d "NetCICD" ] 
then
    echo "NetCICD repo does not exist. Creating..." 
    git init NetCICD
    git config user.name $USER
    cd NetCICD
    git pull https://github.com/Devoteam/NetCICD.git
else
    echo "NetCICD repo exists..."
fi
echo " "
echo "***********************************"
echo " Creating repo in Gitea "
echo "***********************************"
echo " "

curl -X POST http://172.16.11.3:3000/api/v1/user/repos --user $USER:$USER \
     -H  "accept: application/json" \
     -H  "Content-Type: application/json" \
     -d "{  \"auto_init\": false,  \
            \"default_branch\": \"master\",  \
            \"description\": \"The NetCICD version 2 repo\",  \
            \"gitignores\": \"\",  \
            \"issue_labels\": \"\",  \
            \"license\": \"Mozilla\",  \
            \"name\": \"NetCICD\",  \
            \"private\": true,  \
            \"readme\": \"\",  \
            \"template\": true,  \
            \"trust_model\": \"default\"}" > /dev/null

echo " "
echo "***********************************"
echo "Push NetCICD repo to Gitea "
echo "***********************************"
echo " "

git push http://$USER:$USER@172.16.11.3:3000/${USER}/NetCICD.git --all
cd ..

echo " "
echo "***********************************"
echo "Create Develop branch "
echo "***********************************"
curl -X POST "http://172.16.11.3:3000/api/v1/repos/${USER}/NetCICD/branches" --user $USER:$USER -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"new_branch_name\": \"develop\"}"
echo " "
echo "***********************************"
echo "Add git-jenkins user to repo "
echo "***********************************"
curl -X PUT "http://172.16.11.3:3000/api/v1/repos/${USER}/NetCICD/collaborators/git-jenkins" --user git-jenkins:netcicd -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"permission\": \"write\"}"
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
