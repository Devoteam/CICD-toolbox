#!/bin/bash
user=$2
pwd=$1

echo "****************************************************************************************************************"
echo " Adding users to Gitea "
echo "****************************************************************************************************************"
docker exec -it gitea.tooling.test sh -c "su git -c '/usr/local/bin/gitea admin user create --username service-account-jenkins --password netcicd --email service-account-jenkins@tooling.test'"
curl -s --user $user:$pwd -X 'PUT' 'http://gitea.tooling.test:3000/api/v1/teams/1/members/service-account-jenkins'  -H 'accept: application/json' 