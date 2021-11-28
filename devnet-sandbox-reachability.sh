echo "****************************************************************************************************************"
echo " Making sure all containers are reachable locally with the name in the"
echo " hosts file."
echo " " 
sudo chmod o+w /etc/hosts
if grep -q "gitea" /etc/hosts; then
    echo " Gitea exists in /etc/hosts, removing..."
    sudo sed -i '/gitea.tooling.test/d' /etc/hosts
fi
echo " Add Gitea to /etc/hosts"
sudo echo "10.10.20.50   gitea.tooling.test" >> /etc/hosts

if grep -q "jenkins" /etc/hosts; then
    echo " Jenkins exists in /etc/hosts, removing..."
    sudo sed -i '/jenkins.tooling.test/d' /etc/hosts
fi
echo " Add Jenkins to /etc/hosts"
sudo echo "10.10.20.50   jenkins.tooling.test" >> /etc/hosts

if grep -q "nexus" /etc/hosts; then
    echo " Nexus exists in /etc/hosts, removing..."
    sudo sed -i '/nexus.tooling.test/d' /etc/hosts
fi
echo " Add Nexus to /etc/hosts"
sudo echo "10.10.20.50   nexus.tooling.test" >> /etc/hosts

if grep -q "keycloak" /etc/hosts; then
    echo " Keycloak exists in /etc/hosts, removing..."
    sudo sed -i '/keycloak.tooling.test/d' /etc/hosts
fi
echo " Add Keycloak to /etc/hosts"
sudo echo "10.10.20.50   keycloak.tooling.test" >> /etc/hosts

if grep -q "freeipa" /etc/hosts; then
    echo " FreeIPA exists in /etc/hosts, removing..."
    sudo sed -i '/freeipa.tooling.test/d' /etc/hosts
fi
echo " Add FreeIPA to /etc/hosts"
sudo echo "10.10.20.50   freeipa.tooling.test" >> /etc/hosts

if grep -q "portainer" /etc/hosts; then
    echo " Portainer exists in /etc/hosts, removing..."
    sudo sed -i '/portainer.tooling.test/d' /etc/hosts
fi
echo " Add Portainer to /etc/hosts"
sudo echo "10.10.20.50   portainer.tooling.test" >> /etc/hosts

if grep -q "cml" /etc/hosts; then
    echo " Cisco Modeling Labs exists in /etc/hosts, removing..."
    sudo sed -i '/cml.tooling.test/d' /etc/hosts
fi
echo " Add Cisco Modeling Labs to /etc/hosts"
sudo echo "10.10.20.161   cml.tooling.test" >> /etc/hosts

sudo chmod o-w /etc/hosts
