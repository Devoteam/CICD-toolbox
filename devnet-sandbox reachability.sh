echo "****************************************************************************************************************"
echo " Making sure all containers are reachable locally with the name in the"
echo " hosts file."
echo " " 
sudo chmod o+w /etc/hosts
if grep -q "gitea" /etc/hosts; then
    echo " Gitea exists in /etc/hosts"
else
    echo " Add Gitea to /etc/hosts"
    sudo echo "10.10.20.50   gitea" >> /etc/hosts
fi

if grep -q "jenkins" /etc/hosts; then
    echo " Jenkins exists in /etc/hosts"
else
    echo " Add Jenkins to /etc/hosts"
    sudo echo "10.10.20.50   jenkins" >> /etc/hosts
fi

if grep -q "nexus" /etc/hosts; then
    echo " Nexus exists in /etc/hosts"
else
    echo " Add Nexus to /etc/hosts"
    sudo echo "10.10.20.50   nexus" >> /etc/hosts
fi

if grep -q "keycloak" /etc/hosts; then
    echo " Keycloak exists in /etc/hosts"
else
    echo " Add Keycloak to /etc/hosts"
    sudo echo "10.10.20.50   keycloak" >> /etc/hosts
fi

if grep -q "nodered" /etc/hosts; then
    echo " Node Red exists in /etc/hosts"
else
    echo " Add Node Red to /etc/hosts"
    sudo echo "10.10.20.50  nodered" >> /etc/hosts
fi

if grep -q "jupyter" /etc/hosts; then
    echo " Jupyter Notebook exists in /etc/hosts"
else
    echo " Add Jupyter to /etc/hosts"
    sudo echo "10.10.20.50   jupyter" >> /etc/hosts
fi

if grep -q "portainer" /etc/hosts; then
    echo " Portainer exists in /etc/hosts"
else
    echo " Add Portainer to /etc/hosts"
    sudo echo "10.10.20.50   portainer" >> /etc/hosts
fi

if grep -q "cml" /etc/hosts; then
    echo " cml exists in /etc/hosts"
else
    echo " Add Cisco Modeling Labs to /etc/hosts"
    sudo echo "10.10.20.161   cml" >> /etc/hosts
fi
sudo chmod o-w /etc/hosts
