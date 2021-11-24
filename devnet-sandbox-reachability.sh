echo "****************************************************************************************************************"
echo " Making sure all containers are reachable locally with the name in the"
echo " hosts file."
echo " " 
sudo chmod o+w /etc/hosts
if grep -q "gitea" /etc/hosts; then
    echo " Gitea exists in /etc/hosts, removing..."
    sudo sed -i '/gitea/d' /etc/hosts
fi
echo " Add Gitea to /etc/hosts"
sudo echo "10.10.20.50   gitea" >> /etc/hosts

if grep -q "jenkins" /etc/hosts; then
    echo " Jenkins exists in /etc/hosts, removing..."
    sudo sed -i '/jenkins/d' /etc/hosts
fi
echo " Add Jenkins to /etc/hosts"
sudo echo "10.10.20.50   jenkins" >> /etc/hosts

if grep -q "nexus" /etc/hosts; then
    echo " Nexus exists in /etc/hosts, removing..."
    sudo sed -i '/nexus/d' /etc/hosts
fi
echo " Add Nexus to /etc/hosts"
sudo echo "10.10.20.50   nexus" >> /etc/hosts

if grep -q "keycloak" /etc/hosts; then
    echo " Keycloak exists in /etc/hosts, removing..."
    sudo sed -i '/keycloak/d' /etc/hosts
fi
echo " Add Keycloak to /etc/hosts"
sudo echo "10.10.20.50   keycloak" >> /etc/hosts

if grep -q "portainer" /etc/hosts; then
    echo " Portainer exists in /etc/hosts, removing..."
    sudo sed -i '/portainer/d' /etc/hosts
fi
echo " Add Portainer to /etc/hosts"
sudo echo "10.10.20.50   portainer" >> /etc/hosts

if grep -q "cml" /etc/hosts; then
    echo " Cisco Modeling Labs exists in /etc/hosts, removing..."
    sudo sed -i '/cml/d' /etc/hosts
fi
echo " Add Cisco Modeling Labs to /etc/hosts"
sudo echo "10.10.20.161   cml" >> /etc/hosts

sudo chmod o-w /etc/hosts
