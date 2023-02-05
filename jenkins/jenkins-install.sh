#!/bin/bash

# Started with sh -c "jenkins-install.sh ${jenkins_storepass}"

sp="/-\|"
sc=0
spin() {
   printf -- "${sp:sc++:1}  ( ${t} sec.) \r"
   ((sc==${#sp})) && sc=0
   sleep 1
   let t+=1
}

endspin() {
   printf "\r%s\n" "$@"
}
 
echo "****************************************************************************************************************"
echo " Copying Jenkins certificates"
echo "****************************************************************************************************************"
cp vault/certs/jenkins.tooling.provider.test.pem jenkins/jenkins.tooling.provider.test.pem
cp vault/certs/jenkins.tooling.provider.test.crt jenkins/jenkins.tooling.provider.test.crt
echo "****************************************************************************************************************"
echo " Copy certificates into Jenkins keystore"
echo "****************************************************************************************************************"
cat jenkins/jenkins.tooling.provider.test.crt ca.crt > jenkins/import.pem
openssl pkcs12 -export -in jenkins/import.pem -inkey jenkins/jenkins.tooling.provider.test.pem -name jenkins.tooling.provider.test.pem -passout pass:$1 > jenkins/jenkins.p12
#Import the PKCS12 file into Java keystore:
keytool -importkeystore -srckeystore jenkins/jenkins.p12 -destkeystore jenkins/keystore/jenkins.jks -srcstoretype pkcs12 -srcstorepass $1 -storepass $1 -noprompt -deststoretype pkcs12
echo "****************************************************************************************************************"
echo " Starting jenkins"
echo "****************************************************************************************************************"
echo " " 
docker-compose up -d --build --no-deps jenkins.tooling.provider.test
echo "****************************************************************************************************************"
echo " We need a hack to get the CA into Jenkins"
echo "****************************************************************************************************************"
sleep 2
echo " " 
echo "****************************************************************************************************************"
echo " Copy CA certificates into Jenkins keystore"
echo "****************************************************************************************************************"
docker cp jenkins.tooling.provider.test:/opt/java/openjdk/lib/security/cacerts ./jenkins/keystore/cacerts
chmod +w ./jenkins/keystore/cacerts
keytool -import -alias freeipa.tooling.provider.test -keystore ./jenkins/keystore/cacerts -file ./jenkins/ca.crt -storepass $1 -noprompt
docker cp ./jenkins/keystore/cacerts jenkins.tooling.provider.test:/opt/java/openjdk/lib/security/cacerts
echo " " 
echo "****************************************************************************************************************"
echo " putting Jenkins secret in casc file"
echo "****************************************************************************************************************"
#config for oic_auth plugin: need to replace secrets in casc.yaml
jenkins_client_id=$(grep JENKINS_token: install_log/keycloak_create.log | cut -d' ' -f2 | tr -d '\r' )
docker exec -it jenkins.tooling.provider.test sh -c "sed -i -e 's/oic_secret/\"$jenkins_client_id\"/' /var/jenkins_conf/casc.yaml"
echo " " 
echo "****************************************************************************************************************"
echo " Restarting Jenkins"
echo "****************************************************************************************************************"
docker restart jenkins.tooling.provider.test
let t=0
until $(curl --output /dev/null --insecure --silent --head --fail https://jenkins.tooling.provider.test:8084/whoAmI); do
    spin
done
endspin
echo " " 
echo "****************************************************************************************************************"
echo " Downloading agent.jar from jenkins"
echo "****************************************************************************************************************"
if $(curl --output /dev/null --insecure --silent --head --fail https://jenkins.tooling.provider.test:8084/whoAmI); then
    wget --no-check-certificate https://jenkins.tooling.provider.test:8084/jnlpJars/agent.jar
    mv agent.jar jenkins_buildnode/agent.jar
    echo "Retrieved agent.jar from Jenkins and copied to buildnode."
else
    echo "Jenkins not running, no recent agent present"
fi
echo " "
echo "****************************************************************************************************************"
echo " Copying Jenkins Keystore to Jenkins buildnodes"
echo "****************************************************************************************************************"
cp ./jenkins/keystore/cacerts ./jenkins_buildnode/cacerts
