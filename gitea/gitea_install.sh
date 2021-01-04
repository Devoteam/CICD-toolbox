#!/bin/bash 
#script asssumes gitea is running

echo " "
echo "****************************************************************************************************************"
echo " Configuring Gitea"
echo "****************************************************************************************************************"
docker cp gitea/app.ini gitea:/data/gitea/conf/app.ini
echo " "
echo "****************************************************************************************************************"
echo " Adding keycloak client key to Gitea"
gitea_client_id=$(grep GITEA_token keycloak_create.log | cut -d' ' -f3 | tr -d '\r' )
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin auth add-oauth --name keycloak --provider openidConnect --key Gitea --secret $gitea_client_id --auto-discover-url http://keycloak:8080/auth/realms/netcicd/.well-known/openid-configuration --config=/data/gitea/conf/app.ini'"
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
user=gitea-admin
pwd=netcicd
echo " Create local gituser (admin role: $user)"
echo "****************************************************************************************************************"
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username $user --password $pwd --admin --email gitea-admin@infraautomators.example.com --access-token'" > admin_token
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
org_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs" -H "accept: application/json" -H "Content-Type: application/json" --data "${ORG_PAYLOAD}"`
echo " "
echo "****************************************************************************************************************"
echo " Creating NetCICD repo under InfraAutomators organization"
echo "****************************************************************************************************************"
NetCICD_repo_payload='{
    "auth_password": "string",  
    "auth_token": "string",  
    "auth_username": "string",  
    "clone_addr": "https://github.com/Devoteam/NetCICD.git",  
    "description": "The NetCICD toolbox",  
    "issues": true,  
    "labels": true,  
    "milestones": true,  
    "mirror": false,  
    "private": false,  
    "pull_requests": true,  
    "releases": true,  
    "repo_name": "NetCICD",  
    "repo_owner": "infraautomator",  
    "service": "git",  
    "uid": 0,  
    "wiki": true
    }'
curl --user $user:$pwd -X POST "http://gitea:3000/api/v1/repos/migrate" -H  "accept: application/json" -H  "Content-Type: application/json" -d "$NetCICD_repo_payload"
echo " "
echo "****************************************************************************************************************"
echo " Create Develop branch "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X POST "http://gitea:3000/api/v1/repos/infraautomator/NetCICD/branches" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"new_branch_name\": \"develop\"}"
echo " "
echo "****************************************************************************************************************"
echo " Creating webhook for the repo"
echo "****************************************************************************************************************"
NetCICD_webhook_payload='{
    "active": true,
    "branch_filter": "*",
    "config": {
        "content_type": "json",
        "url": "http://jenkins:8080/gitea-webhook/post"
        },
    "events": [ "push" ],
    "type": "gitea"
    }'
curl --user gitea-admin:netcicd -X POST "http://gitea:3000/api/v1/repos/infraautomator/NetCICD/hooks" -H  "accept: application/json" -H  "Content-Type: application/json" -d "$NetCICD_webhook_payload"
echo " "
echo "****************************************************************************************************************"
echo " Creating NetCICD-development-toolbox repo under InfraAutomators organization"
echo "****************************************************************************************************************"
NetCICD_repo_payload='{
    "auth_password": "string",  
    "auth_token": "string",  
    "auth_username": "string",  
    "clone_addr": "https://github.com/Devoteam/NetCICD-developer-toolbox.git",  
    "description": "The NetCICD toolbox",  
    "issues": true,  
    "labels": true,  
    "milestones": true,  
    "mirror": false,  
    "private": false,  
    "pull_requests": true,  
    "releases": true,  
    "repo_name": "NetCICD-developer-toolbox",  
    "repo_owner": "infraautomator",  
    "service": "git",  
    "uid": 0,  
    "wiki": true
    }'
curl --user $user:$pwd -X POST "http://gitea:3000/api/v1/repos/migrate" -H  "accept: application/json" -H  "Content-Type: application/json" -d "$NetCICD_repo_payload"
echo " "
echo "****************************************************************************************************************"
echo " Create Develop branch "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X POST "http://gitea:3000/api/v1/repos/infraautomator/NetCICD-developer-toolbox/branches" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"new_branch_name\": \"develop\"}"
echo " "
echo "****************************************************************************************************************"
echo " Creating webhook for the repo"
echo "****************************************************************************************************************"
echo " "
NetCICD_developer_toolbox_webhook_payload='{
    "active": true,
    "branch_filter": "*",
    "config": {
        "content_type": "json",
        "url": "http://jenkins:8080/gitea-webhook/post"
        },
    "events": [ "push" ],
    "type": "gitea"
    }'
curl --user gitea-admin:netcicd -X POST "http://gitea:3000/api/v1/repos/infraautomator/NetCICD-developer-toolbox/hooks" -H  "accept: application/json" -H  "Content-Type: application/json" -d "$NetCICD_developer_toolbox_webhook_payload"
echo " "
echo "****************************************************************************************************************"
echo " Creating gitea-netops-read team in Gitea "
echo "****************************************************************************************************************"
netops_team_read_payload='{ 
    "can_create_org_repo": false, 
    "description": "The network operators team - readonly", 
    "includes_all_repositories": false, 
    "name": "gitea-netops-read", 
    "permission": "read", 
    "units": [ 
        "repo.code", 
        "repo.issues", 
        "repo.ext_issues", 
        "repo.wiki", 
        "repo.pulls", 
        "repo.releases", 
        "repo.ext_wiki" 
        ] 
    }'
netops_team_read_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infraautomator/teams" -H "accept: application/json" -H "Content-Type: application/json" -d "${netops_team_read_payload}"`
netops_team_read_id=$( echo $netops_team_read_data | awk -F',' '{print $(1)}' | awk -F':' '{print $2}' )
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD repo to gitea-netops-read team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netops_team_read_id/repos/infraautomator/NetCICD" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD-development-toolbox repo to gitea-netops-read team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netops_team_read_id/repos/infraautomator/NetCICD-developer-toolbox" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Creating gitea-netops-write team in Gitea "
echo "****************************************************************************************************************"
netops_team_write_payload='{ 
    "can_create_org_repo": true, 
    "description": "The network specialists team - can write", 
    "includes_all_repositories": false, 
    "name": "gitea-netops-write", 
    "permission": "write", 
    "units": [ 
        "repo.code", 
        "repo.issues", 
        "repo.ext_issues", 
        "repo.wiki", 
        "repo.pulls", 
        "repo.releases", 
        "repo.ext_wiki" 
        ] 
    }'
netops_team_write_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infraautomator/teams" -H "accept: application/json" -H "Content-Type: application/json" -d "${netops_team_write_payload}"`
netops_team_write_id=$( echo $netops_team_write_data | awk -F',' '{print $(1)}' | awk -F':' '{print $2}' )
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD repo to gitea-netops-write team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netops_team_write_id/repos/infraautomator/NetCICD" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Creating gitea-netdev-read team in Gitea "
echo "****************************************************************************************************************"
netdev_team_read_payload='{ 
    "can_create_org_repo": false, 
    "description": "The network architecture team - readonly", 
    "includes_all_repositories": false, 
    "name": "gitea-netdev-read", 
    "permission": "read", 
    "units": [
        "repo.code",
        "repo.issues",
        "repo.ext_issues",
        "repo.wiki",
        "repo.pulls",
        "repo.releases",
        "repo.ext_wiki"
        ]
    }'
netdev_team_read_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infraautomator/teams" -H "accept: application/json" -H "Content-Type: application/json" -d "${netdev_team_read_payload}"`
netdev_team_read_id=$( echo $netdev_team_read_data | awk -F',' '{print $(1)}' | awk -F':' '{print $2}' )
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD repo to gitea-netdev-read team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netdev_team_read_id/repos/infraautomator/NetCICD" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD-development-toolbox repo to gitea-netdev-read team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netdev_team_read_id/repos/infraautomator/NetCICD-developer-toolbox" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Creating gitea-netdev-write team in Gitea "
echo "****************************************************************************************************************"
netdev_team_write_payload='{ 
    "can_create_org_repo": true, 
    "description": "The network architecture team - can write", 
    "includes_all_repositories": false, 
    "name": "gitea-netdev-write", 
    "permission": "write", 
    "units": [
        "repo.code",
        "repo.issues",
        "repo.ext_issues",
        "repo.wiki",
        "repo.pulls",
        "repo.releases",
        "repo.ext_wiki"
        ]
    }'
netdev_team_write_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infraautomator/teams" -H "accept: application/json" -H "Content-Type: application/json" -d "${netdev_team_write_payload}"`
netdev_team_write_id=$( echo $netdev_team_write_data | awk -F',' '{print $(1)}' | awk -F':' '{print $2}' )
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD repo to gitea-netdev-write team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netdev_team_write_id/repos/infraautomator/NetCICD" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Creating gitea-tooling-read team in Gitea "
echo "****************************************************************************************************************"
tooling_team_read_payload='{ 
    "can_create_org_repo": false, 
    "description": "The tooling team - read-only", 
    "includes_all_repositories": false, 
    "name": "gitea-tooling-read", 
    "permission": "read", 
    "units": [
        "repo.code",
        "repo.issues",
        "repo.ext_issues",
        "repo.wiki",
        "repo.pulls",
        "repo.releases",
        "repo.ext_wiki"
        ]
    }'
tooling_team_read_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infraautomator/teams" -H "accept: application/json" -H "Content-Type: application/json" -d "${tooling_team_read_payload}"`
tooling_team_read_id=$( echo $tooling_team_read_data | awk -F',' '{print $(1)}' | awk -F':' '{print $2}' )
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD repo to gitea-tooling-read team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$tooling_team_read_id/repos/infraautomator/NetCICD" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD-development-toolbox repo to gitea-tooling-read team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$tooling_team_read_id/repos/infraautomator/NetCICD-developer-toolbox" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Creating gitea-tooling-write team in Gitea "
echo "****************************************************************************************************************"
tooling_team_write_payload='{ 
    "can_create_org_repo": true, 
    "description": "The tooling team - can write", 
    "includes_all_repositories": false, 
    "name": "gitea-tooling-write", 
    "permission": "write", 
    "units": [
        "repo.code",
        "repo.issues",
        "repo.ext_issues",
        "repo.wiki",
        "repo.pulls",
        "repo.releases",
        "repo.ext_wiki"
        ]
    }'
tooling_team_write_data=`curl -s --user $user:$pwd -X POST "http://gitea:3000/api/v1/orgs/infraautomator/teams" -H "accept: application/json" -H "Content-Type: application/json" -d "${tooling_team_write_payload}"`
tooling_team_write_id=$( echo $tooling_team_write_data | awk -F',' '{print $(1)}' | awk -F':' '{print $2}' )
echo " "
echo "****************************************************************************************************************"
echo " Adding NetCICD-development-toolbox repo to gitea-tooling-write team in Gitea "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$tooling_team_write_id/repos/infraautomator/NetCICD-developer-toolbox" -H  "accept: application/json"
echo " "
echo "****************************************************************************************************************"
echo " Adding users to Gitea "
echo "****************************************************************************************************************"
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username git-jenkins --password netcicd --email git-jenkins@infraautomators.example.com --access-token'" > git-jenkins_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username thedude --password thedude --email thedude@infraautomators.example.com --access-token'" > thedude_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username thespecialist --password thespecialist --email thespecialist@infraautomators.example.com --access-token'" > thespecialist_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username architect --password architect --email architect@infraautomators.example.com --access-token'" > architect_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username networkguru --password networkguru --email networkguru@infraautomators.example.com --access-token'" > networkguru_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username hacker --password whitehat --email hacker@infraautomators.example.com --access-token'" > hacker_token
docker exec -it gitea sh -c "su git -c '/usr/local/bin/gitea admin user create --username tooltiger --password tooltiger --email tooltiger@infraautomators.example.com --access-token'" > tooltiger_token
# as Gitea cannot honor groups from keycloak, we must add the users to the groups separately
echo " "
echo "****************************************************************************************************************"
echo " Assigning users to teams "
echo "****************************************************************************************************************"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netdev_team_write_id/members/git-jenkins" -H  "accept: application/json"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$tooling_team_write_id/members/git-jenkins" -H  "accept: application/json"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netops_team_read_id/members/thedude" -H  "accept: application/json"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netops_team_write_id/members/thespecialist" -H  "accept: application/json"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netdev_team_read_id/members/architect" -H  "accept: application/json"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$netdev_team_write_id/members/networkguru" -H  "accept: application/json"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$tooling_team_read_id/members/hacker" -H  "accept: application/json"
curl --user $user:$pwd -X PUT "http://gitea:3000/api/v1/teams/$tooling_team_write_id/members/tooltiger" -H  "accept: application/json"
