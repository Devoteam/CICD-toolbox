#!/bin/bash 

create_runner_node() {
    sleep 5
    echo "****************************************************************************************************************"
    echo " Creating Gitea runner for ${1} with name ${4} and sequence number ${3}"
    echo "****************************************************************************************************************"
    robot --variable environment:$1 --variable VALID_PASSWORD:$2 -d install_log -o .30_build-$1_runner_create.xml -l 30_build-$1_runner_create_log.html -r 30_build-$1_runner_create_report.html jenkins_buildnode/runnertoken.robot
    export RUNNER_TOKEN=$(cat jenkins_buildnode/${1}_runner_token)
    echo $RUNNER_TOKEN
    docker compose --project-name cicd-toolbox up -d --build --no-deps --force-recreate build-$1.delivery.provider.test
    docker exec --user root -it build-$1.delivery.provider.test sh -c "source /etc/rc.local"

    echo "****************************************************************************************************************"
    echo " Validating Gitea runner for ${1} with name ${4} and sequence number ${3}"
    echo "****************************************************************************************************************"
    robot --variable ENVIRONMENT:$1 --variable VALID_PASSWORD:$2 --variable SEQ_NR:$3 --variable NAME:$4 -d install_log/ -o 31_build-$1_runner_test.xml -l 31_build-$1_runner_test_log.html -r 31_build-$1_runner_test_report.html ./jenkins_buildnode/runner_validate.robot
}

if [ -f "jenkins_buildnode/act_runner-0.2.6-linux-amd64" ]; then
    echo " Gitea runner software exists"
else
    echo " Get Gitea runner software"
    wget --directory-prefix=jenkins_buildnode https://dl.gitea.com/act_runner/0.2.6/act_runner-0.2.6-linux-amd64
fi
chmod +x  jenkins_buildnode/act_runner-0.2.6-linux-amd64
create_runner_node "dev" $1 1 "Dev"
create_runner_node "test" $1 2 "Test"
create_runner_node "acc" $1 3 "Acc"
create_runner_node "prod" $1 4 "Prod"