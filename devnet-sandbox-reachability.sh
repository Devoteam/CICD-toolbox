echo "****************************************************************************************************************"
echo " Making sure all containers are reachable locally with the name in the"
echo " hosts file."
echo " " 
sudo chmod o+w /etc/hosts
if grep -q "gitea" /etc/hosts; then
    echo " Gitea exists in /etc/hosts, removing..."
    sudo sed '/gitea/d' /etc/hosts
fi
echo " Add Gitea to /etc/hosts"
sudo echo "10.10.20.50   gitea" >> /etc/hosts

if grep -q "jenkins" /etc/hosts; then
    echo " Jenkins exists in /etc/hosts, removing..."
    sudo sed '/jenkins/d' /etc/hosts
fi
echo " Add Jenkins to /etc/hosts"
sudo echo "10.10.20.50   jenkins" >> /etc/hosts

if grep -q "nexus" /etc/hosts; then
    echo " Nexus exists in /etc/hosts, removing..."
    sudo sed '/nexus/d' /etc/hosts
fi
echo " Add Nexus to /etc/hosts"
sudo echo "10.10.20.50   nexus" >> /etc/hosts

if grep -q "keycloak" /etc/hosts; then
    echo " Keycloak exists in /etc/hosts, removing..."
    sudo sed '/keycloak/d' /etc/hosts
fi
echo " Add Keycloak to /etc/hosts"
sudo echo "10.10.20.50   keycloak" >> /etc/hosts

if grep -q "nodered" /etc/hosts; then
    echo " NodeRed exists in /etc/hosts, removing..."
    sudo sed '/nodered/d' /etc/hosts
fi
echo " Add NodeRed to /etc/hosts"
sudo echo "10.10.20.50   nodered" >> /etc/hosts

if grep -q "jupyter" /etc/hosts; then
    echo " Jupyter Notebook exists in /etc/hosts, removing..."
    sudo sed '/jupyter/d' /etc/hosts
fi
echo " Add Jupyter Notebook to /etc/hosts"
sudo echo "10.10.20.50   jupyter" >> /etc/hosts

if grep -q "portainer" /etc/hosts; then
    echo " Portainer exists in /etc/hosts, removing..."
    sudo sed '/portainer/d' /etc/hosts
fi
echo " Add Portainer to /etc/hosts"
sudo echo "10.10.20.50   portainer" >> /etc/hosts

if grep -q "cml" /etc/hosts; then
    echo " Cisco Modeling Labs exists in /etc/hosts, removing..."
    sudo sed '/cml/d' /etc/hosts
fi
echo " Add Cisco Modeling Labs to /etc/hosts"
sudo echo "10.10.20.161   cml" >> /etc/hosts

sudo chmod o-w /etc/hosts
