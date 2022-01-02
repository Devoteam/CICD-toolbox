#!/bin/bash
user=$2
pwd=$1

#First define functions

function CreateRepo () {   
    # Call via CreateRepo infraautomator NetCICD "https://github.com/Devoteam/NetCICD.git" "The NetCICD pipeline"
    echo "****************************************************************************************************************"
    echo " Creating ${2} repo under ${1} organization"
    echo "****************************************************************************************************************"
    local repo_payload='{
        "auth_password": "string",  
        "auth_token": "string",  
        "auth_username": "string",  
        "clone_addr": "'$3'",  
        "description": "'$4'",  
        "issues": false,  
        "labels": false,  
        "milestones": false,  
        "mirror": false,  
        "private": false,  
        "pull_requests": false,  
        "releases": false,  
        "repo_name": "'$2'",  
        "repo_owner": "'$1'",  
        "service": "git",  
        "uid": 0,  
        "wiki": false
        }'
    curl -s --user $user:$pwd -X POST "http://gitea.tooling.test:3000/api/v1/repos/migrate" -H  "accept: application/json" -H  "Content-Type: application/json" -d "${repo_payload}"
    echo " "
    echo "****************************************************************************************************************"
    echo " Creating webhook for the ${2} repo"
    echo "****************************************************************************************************************"
    local webhook_payload='{
        "active": true,
        "branch_filter": "*",
        "config": {
            "content_type": "json",
            "url": "http://jenkins.tooling.test:8084/gitea-webhook/post"
            },
        "events": [ "push" ],
        "type": "gitea"
        }'
    curl -s --user $user:$pwd -X POST "http://gitea.tooling.test:3000/api/v1/repos/${1}/${2}/hooks" -H  "accept: application/json" -H  "Content-Type: application/json" -d "${webhook_payload}"
    echo " "    
}

function CreateTeam () {
    # Call via CreateTeam infraautomator "gitea-netcicd-read" "The NetCICD repo read role" "read" NetCICD
    echo "****************************************************************************************************************"
    echo " Creating ${2} team in Gitea "
    echo "****************************************************************************************************************"
    local team_payload='{ 
        "can_create_org_repo": false, 
        "description": "'$3'", 
        "includes_all_repositories": false, 
        "name": "'$2'", 
        "permission": "'$4'", 
        "units": [ 
            "repo.code", 
            "repo.issues", 
            "repo.ext_issues", 
            "repo.wiki", 
            "repo.pulls", 
            "repo.releases", 
            "repo.projects",
            "repo.ext_wiki" 
            ] 
        }'
    local team_data=`curl -s --user $user:$pwd -X POST "http://gitea.tooling.test:3000/api/v1/orgs/${1}/teams" -H "accept: application/json" -H "Content-Type: application/json" -d "${team_payload}"`
    local team_id=$( echo $team_data | awk -F',' '{print $(1)}' | awk -F':' '{print $2}' )
    echo " "
    echo "****************************************************************************************************************"
    echo " Adding ${5} repo to ${2} team in Gitea "
    echo "****************************************************************************************************************"
    curl -s --user $user:$pwd -X PUT "http://gitea.tooling.test:3000/api/v1/teams/${team_id}/repos/infraautomator/${5}" -H  "accept: application/json"
    echo " "

    team=$team_id
}


#script asssumes gitea is running
echo "****************************************************************************************************************"
echo " Wait until Gitea has started"
echo "****************************************************************************************************************"
docker restart gitea.tooling.test
until $(curl --output /dev/null --silent --head --fail http://gitea.tooling.test:3000); do
    printf '.'
    sleep 5
done
echo " "
echo "****************************************************************************************************************"
echo " Configuring Gitea"
echo "****************************************************************************************************************"
docker cp gitea/app.ini gitea.tooling.test:/data/gitea/conf/app.ini
echo " "
echo "****************************************************************************************************************"
echo " Create local gituser (admin role: $user)"
echo "****************************************************************************************************************"
docker exec -it gitea.tooling.test sh -c "su git -c '/usr/local/bin/gitea admin user create --username $user --password $pwd --admin --email gitea-local-admin@tooling.test'"
echo " "
echo "****************************************************************************************************************"
echo " Creating InfraAutomators organization in Gitea "
echo "****************************************************************************************************************"
ORG_PAYLOAD='{ 
    "description": "Infrastructure automation transformation team", 
    "full_name": "InfraAutomators", 
    "location": "Github",
    "repo_admin_change_team_access": true,
    "username": "infraautomator",
    "visibility": "public", 
    "website": ""
    }'
org_data=`curl -s --user $user:$pwd -X POST "http://gitea.tooling.test:3000/api/v1/orgs" -H "accept: application/json" -H "Content-Type: application/json" --data "${ORG_PAYLOAD}"`
echo " "

CreateRepo "Infraautomator" "NetCICD" "https://github.com/Devoteam/NetCICD.git" "The NetCICD pipeline"
CreateRepo "Infraautomator" "CICD-toolbox" "https://github.com/Devoteam/CICD-toolbox.git" "The CICD-toolbox"

CreateTeam infraautomator "gitea-netcicd-read" "The NetCICD repo read role" "read" "NetCICD"
CreateTeam infraautomator "gitea-netcicd-write" "The NetCICD repo read-write role" "write" "NetCICD"
CreateTeam infraautomator "gitea-netcicd-admin" "The NetCICD repo admin role" "admin" "NetCICD"
CreateTeam infraautomator "gitea-CICDtoolbox-read" "The CICDtoolbox repo read role" "read" "CICD-toolbox"
CreateTeam infraautomator "gitea-CICDtoolbox-write" "The CICDtoolbox repo read-write role" "write" "CICD-toolbox"
CreateTeam infraautomator "gitea-CICDtoolbox-admin" "The CICDtoolbox repo admin role" "admin" "CICD-toolbox"
echo "****************************************************************************************************************"
echo " Adding keycloak client key to Gitea"
gitea_client_id=$(grep GITEA_token install_log/keycloak_create.log | cut -d' ' -f2 | tr -d '\r' )
docker exec -it gitea.tooling.test sh -c "su git -c '/usr/local/bin/gitea admin auth add-oauth --name keycloak --provider openidConnect --key Gitea --secret $gitea_client_id --auto-discover-url http://keycloak.tooling.test:8080/auth/realms/netcicd/.well-known/openid-configuration --config=/data/gitea/conf/app.ini'"
echo "****************************************************************************************************************"
echo " Restarting Gitea"
echo "****************************************************************************************************************"
docker restart gitea.tooling.test
echo " Wait until gitea is running"
until $(curl --output /dev/null --silent --head --fail http://gitea.tooling.test:3000); do
    printf '.'
    sleep 5
done
echo " "
