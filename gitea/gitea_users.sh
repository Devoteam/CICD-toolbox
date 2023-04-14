#!/bin/bash
user=$2
pwd=$1

echo "****************************************************************************************************************"
echo " Adding users to Gitea "
echo "****************************************************************************************************************"
docker exec -it gitea.tooling.provider.test sh -c "su git -c '/usr/local/bin/gitea admin user create --username Jenkins --password '${pwd}' --email jenkins@tooling.provider.test'"
curl -s --insecure --user $user:$pwd -X 'PUT' 'https://gitea.tooling.provider.test:3000/api/v1/teams/1/members/Jenkins'  -H 'accept: application/json' 