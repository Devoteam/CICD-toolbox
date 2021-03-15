#!/bin/bash 

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
echo " Cleaning Gerrit" 
echo "****************************************************************************************************************"
sudo rm -rf gerrit/etc/*
sudo rm -rf gerrit/db/*
sudo rm -rf gerrit/cache/*
sudo rm -rf gerrit/git/*
sudo rm -rf gerrit/index/*
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
echo " Making sure all containers are reachable locally with the name in the"
echo " hosts file."
echo " " 
sudo chmod o+w /etc/hosts
if grep -q "gitea" /etc/hosts; then
    echo " Gitea exists in /etc/hosts"
else
    echo " Add Gitea to /etc/hosts"
    sudo echo "172.16.11.3   gitea" >> /etc/hosts
fi

if grep -q "gerrit" /etc/hosts; then
    echo " Gerrit exists in /etc/hosts"
else
    echo " Add Gerrit to /etc/hosts"
    sudo echo "172.16.11.7   gerrit" >> /etc/hosts
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
    echo " Add Portainer to /etc/hosts"
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
docker-compose up -d --build --remove-orphans  
echo " " 
echo "****************************************************************************************************************"
echo " Use docker-compose up -d or ./up next time"
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
echo " Adding keycloak RADIUS plugin"
echo "****************************************************************************************************************"
docker exec -it keycloak sh -c "/opt/radius/scripts/keycloak.sh"
echo " " 
echo "Reloading "
docker restart keycloak
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
echo " Creating gitea setup"
echo "****************************************************************************************************************"
gitea/gitea_install.sh
echo " " 
echo "****************************************************************************************************************"
echo " Creating jenkins setup"
echo "****************************************************************************************************************"
#token for gitea_jenkins user: only need to replace git_jenkins_token in casc.yaml
#git_jenkins_token=$(grep GIT-JENKINS_token keycloak_create.log | cut -d' ' -f3 | tr -d '\r' )
#docker exec -it jenkins sh -c "sed -i -e 's/git_jenkins_token/\"$git_jenkins_token\"/' /var/jenkins_conf/casc.yaml"
#config for ioc_auth plugin: only need to replace secret in casc.yaml
jenkins_client_id=$(grep JENKINS_token keycloak_create.log | cut -d' ' -f3 | tr -d '\r' )
docker exec -it jenkins sh -c "sed -i -e 's/oic_secret/\"$jenkins_client_id\"/' /var/jenkins_conf/casc.yaml"
echo "Reloading "
docker restart jenkins
echo " " 
echo "****************************************************************************************************************"
echo " Creating nexus setup"
echo "****************************************************************************************************************"
docker cp keycloak:/opt/jboss/keycloak/bin/keycloak-nexus.json nexus/keycloak-nexus.json
docker cp nexus/keycloak-nexus.json nexus:/opt/sonatype/nexus/etc/keycloak.json
echo "Reloading "
docker restart nexus
until $(curl --output /dev/null --silent --head --fail http://nexus:8081); do
    printf '.'
    sleep 5
done
echo " " 
echo "****************************************************************************************************************"
echo " Saving Keycloak self-signed certificate"
openssl s_client -showcerts -connect keycloak:8443 </dev/null 2>/dev/null|openssl x509 -outform PEM >./jenkins/keystore/keycloak.pem
echo " "
echo " Copy certificate into Jenkins keystore"
echo "****************************************************************************************************************"
docker cp jenkins:/opt/java/openjdk/jre/lib/security/cacerts ./jenkins/keystore/cacerts
chmod +w ./jenkins/keystore/cacerts
keytool -import -alias Keycloak -keystore ./jenkins/keystore/cacerts -file ./jenkins/keystore/keycloak.pem -storepass changeit -noprompt
docker cp ./jenkins/keystore/cacerts jenkins:/opt/java/openjdk/jre/lib/security/cacerts
echo "Reloading "
docker restart jenkins
until $(curl --output /dev/null --silent --head --fail http://jenkins:8080/whoAmI); do
    printf '.'
    sleep 5
done
echo " " 
echo "****************************************************************************************************************"
echo "NetCICD Toolkit install done "
echo " "
echo "You can reach the servers on:"
echo " "
echo " Gitea:       http://gitea:3000"
echo " Jenkins:     http://jenkins:8080"
echo " Gerrit:      http://gerrit:8080"
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
