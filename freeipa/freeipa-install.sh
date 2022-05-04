#!/bin/bash 
echo $2 | kinit admin

function addHost() {
    ipa host-add --force --ip-address=$3 $1.$2.provider.test
    ipa service-add HTTP/$1.$2.provider.test
    ipa-getkeytab -p HTTP/$1.$2.provider.test -s freeipa.services.provider.test -k /etc/krb5-$1.keytab
    chown root /etc/krb5-$1.keytab
    chmod 640 /etc/krb5-$1.keytab
    ipa cert-request /tmp/certs/$1.$2.provider.test.csr --principal=host/$1.$2.provider.test --chain --certificate-out=/tmp/certs/$1.$2.provider.test.pem
}

# Add Groups
ipa group-add toolbox --desc="Toolbox Roles"
ipa group-add toolbox_admin --desc="Toolbox-Admins"
ipa group-add cicd_agents --desc="CICD-agents that connect back to Jenkins"
ipa group-add git_from_jenkins --desc="Group that is permitted to read git to update repo's from Jenkins"
ipa group-add-member toolbox --groups=toolbox_admin --groups=cicd_agents --groups=git_from_jenkins

# Add users
echo $1 | ipa user-add netcicd --first=NetCICD --last=Godmode --email=netcicd@provider.test --user-auth-type='password' --password
ipa group-add-member Toolbox_admin --user=netcicd

echo $1 | ipa user-add jenkins-git --first=Jenkins --last=Git --email=jenkins-git@provider.test --user-auth-type='password' --password
ipa group-add-member git_from_jenkins --user=jenkins-git

echo $1 | ipa user-add jenkins-jenkins --first=Jenkins --last=Jenkins --email=jenkins-jenkins@provider.test --user-auth-type='password' --password
ipa group-add-member cicd_agents --user=jenkins-jenkins

ipa group-add iam --desc="IAM"
ipa group-add iam_ops --desc="IAM Operations"
ipa group-add iam_ops_oper --desc="IAM Operations - Operators"
ipa group-add iam_ops_spec --desc="IAM Operations - Specialists"
ipa group-add-member iam_ops --groups=iam_ops_oper --groups=iam_ops_spec
ipa group-add iam_dev --desc="IAM Development"
ipa group-add-member iam --groups=iam_ops --groups=iam_dev

ipa group-add office --desc="Office"
ipa group-add office_ops --desc="Office Operations"
ipa group-add office_dev --desc="Office Development"
ipa group-add-member office --groups=office_ops --groups=office_dev
ipa group-add office_ops_oper --desc="Office Operations - Operators"
ipa group-add office_ops_spec --desc="Office Operations - Specialists"
ipa group-add-member office_ops --groups=office_ops_oper --groups=office_ops_spec

ipa group-add campus --desc="Campus"
ipa group-add campus_ops --desc="Campus Operations"
ipa group-add campus_dev --desc="Campus Development"
ipa group-add-member campus --groups=campus_ops --groups=campus_dev
# Define Operator and specialist groups
ipa group-add campus_ops_oper --desc="Campus Operations - Operators"
echo $1 | ipa user-add campusoper --first=Campus --last=Oper --email=campusoper@provider.test --user-auth-type='password' --password
ipa group-add-member campus_ops_oper --user=campusoper
#
ipa group-add campus_ops_spec --desc="Campus Operations - Specialists"
echo $1 | ipa user-add campusspec --first=Campus --last=Spec --email=campusspec@provider.test --user-auth-type='password' --password
ipa group-add-member campus_ops_spec --user=campusspec
# Link Operations groups
ipa group-add-member campus_ops --groups=campus_ops_oper --groups=campus_ops_spec
# Define Dev groups
ipa group-add campus_dev_lan --desc="Campus Development - LAN Designer"
echo $1 | ipa user-add campuslandev --first=Campus --last=LanDev --email=campuslandev@provider.test --user-auth-type='password' --password
ipa group-add-member campus_dev_lan --user=campuslandev
#
ipa group-add campus_dev_wifi --desc="Campus Development - WIFI designer"
echo $1 | ipa user-add campuswifidev --first=Campus --last=WifiDev --email=campuswifidev@provider.test --user-auth-type='password' --password
ipa group-add-member campus_dev_wifi --user=campuswifidev
#
ipa group-add-member campus_dev --groups=campus_dev_lan --groups=campus_dev_wifi

ipa group-add wan --desc="WAN"
ipa group-add wan_ops --desc="WAN Operations"
ipa group-add wan_dev --desc="WAN Development"
ipa group-add-member wan --groups=wan_ops --groups=wan_dev
# Define Operator and specialist groups
ipa group-add wan_ops_oper --desc="WAN Operations - Operators"
echo $1 | ipa user-add wanoper --first=Wan --last=Oper --email=wanoper@provider.test --user-auth-type='password' --password
ipa group-add-member wan_ops_oper --user=wanoper
#
ipa group-add wan_ops_spec --desc="WAN Operations - Specialists"
echo $1 | ipa user-add wanspec --first=Wan --last=Spec --email=wanspec@provider.test --user-auth-type='password' --password
ipa group-add-member wan_ops_spec --user=wanspec
# Link Operations groups
ipa group-add-member wan_ops --groups=wan_ops_oper --groups=wan_ops_spec
# Define Dev groups
ipa group-add wan_dev_design --desc="WAN Designer"
echo $1 | ipa user-add corearchitect --first=Core --last=Architect --email=corearchitect@provider.test --user-auth-type='password' --password
ipa group-add-member wan_dev_design --user=corearchitect
#
ipa group-add-member wan_dev --groups=wan_dev_design

ipa group-add dc --desc="Datacenter"
ipa group-add dc_ops --desc="Datacenter Operations"
ipa group-add dc_dev --desc="Datacenter Development"
ipa group-add-member dc --groups=dc_ops --groups=dc_dev
# Define Operations groups
ipa group-add dc_ops_compute --desc="Datacenter Compute Operations"
# Define Operator and specialist groups
ipa group-add dc_ops_compute_oper --desc="Datacenter Compute Operations - Operators"
echo $1 | ipa user-add compudude --first=Compu --last=Dude --email=compudude@provider.test --user-auth-type='password' --password
ipa group-add-member dc_ops_compute_oper --user=compudude
#
ipa group-add dc_ops_compute_spec --desc="Datacenter Compute Operations - Specialists"
echo $1 | ipa user-add compuspecialist --first=Compu --last=Specialist --email=compuspecialist@provider.test --user-auth-type='password' --password
ipa group-add-member dc_ops_compute_spec --user=compuspecialist
# Link Operations groups
ipa group-add-member dc_ops_compute --groups=dc_ops_compute_oper --groups=dc_ops_compute_spec
#
ipa group-add dc_ops_network --desc="Datacenter Network Operations"
# Define Operator and specialist groups
ipa group-add dc_ops_network_oper --desc="Datacenter Network Operations - Operators"
echo $1 | ipa user-add netdude --first=Net --last=Dude --email=netdude@provider.test --user-auth-type='password' --password
ipa group-add-member dc_ops_network_oper --user=netdude
#
ipa group-add dc_ops_network_spec --desc="Datacenter Network Operations - Specialists"
echo $1 | ipa user-add netspecialist --first=Net --last=Specialist --email=netspecialist@provider.test --user-auth-type='password' --password
ipa group-add-member dc_ops_network_spec --user=netspecialist
# Link Operations groups
ipa group-add-member dc_ops_network --groups=dc_ops_network_oper --groups=dc_ops_network_spec
#
ipa group-add dc_ops_storage --desc="Datacenter Storage Operations"
# Define Operator and specialist groups
ipa group-add dc_ops_storage_oper --desc="Datacenter Storage Operations - Operators"
echo $1 | ipa user-add diskdude --first=Disk --last=Dude --email=diskdude@provider.test --user-auth-type='password' --password
ipa group-add-member dc_ops_storage_oper --user=diskdude
#
ipa group-add dc_ops_storage_spec --desc="Datacenter Storage Operations - Specialists"
echo $1 | ipa user-add diskspecialist --first=Disk --last=Specialist --email=diskspecialist@provider.test --user-auth-type='password' --password
ipa group-add-member dc_ops_storage_spec --user=diskspecialist
# Link Operations groups
ipa group-add-member dc_ops_storage --groups=dc_ops_storage_oper --groups=dc_ops_storage_spec
# Link Operations groups
ipa group-add-member dc_ops --groups=dc_ops_compute --groups=dc_ops_network --groups=dc_ops_storage
# Define Dev groups
ipa group-add dc_dev_compute --desc="Datacenter Compute Development"
echo $1 | ipa user-add compuarchitect --first=Compu --last=Architect --email=compuarchitect@provider.test --user-auth-type='password' --password
ipa group-add-member dc_dev_compute --user=compuarchitect
#
ipa group-add dc_dev_network --desc="Datacenter Network Development"
echo $1 | ipa user-add netarchitect --first=Net --last=Architect --email=netarchitect@provider.test --user-auth-type='password' --password
ipa group-add-member dc_dev_network --user=netarchitect
#
ipa group-add dc_dev_storage --desc="Datacenter Storage Development"
echo $1 | ipa user-add diskarchitect --first=Disk --last=Architect --email=diskarchitect@provider.test --user-auth-type='password' --password
ipa group-add-member dc_dev_storage --user=diskarchitect
# Link Development groups
ipa group-add-member dc_dev --groups=dc_dev_compute --groups=dc_dev_network --groups=dc_dev_storage

ipa group-add app --desc="Application"
ipa group-add app_ops --desc="Application Operations"
ipa group-add app_dev --desc="Application Development"
ipa group-add-member app --groups=app_ops --groups=app_dev

ipa group-add tooling --desc="Tooling"
ipa group-add tooling_ops --desc="Tooling Operations"
ipa group-add tooling_dev --desc="Tooling Development"
ipa group-add-member tooling --groups=tooling_ops --groups=tooling_dev
# Define Operations groups
ipa group-add tooling_ops_oper --desc="Tooling Operations - Operators"
echo $1 | ipa user-add tooltiger --first=Tool --last=Tiger --email=tooltiger@provider.test --user-auth-type='password' --password
ipa group-add-member tooling_ops_oper --user=tooltiger
#
ipa group-add tooling_ops_spec --desc="Tooling Operations - Specialists"
echo $1 | ipa user-add toolmaster --first=Tool --last=Master --email=toolmaster@provider.test --user-auth-type='password' --password
ipa group-add-member tooling_ops_spec --user=toolmaster
# Link Operations groups
ipa group-add-member tooling_ops --groups=tooling_ops_oper --groups=tooling_ops_spec
# Define Dev groups
ipa group-add tooling_dev_design --desc="Tooling Designer"
echo $1 | ipa user-add blacksmith --first=Black --last=Smith --email=blacksmith@provider.test --user-auth-type='password' --password
ipa group-add-member tooling_dev_design --user=blacksmith
#
ipa group-add-member tooling_dev --groups=tooling_dev_design

ipa group-add security --desc="Security"
ipa group-add security_ops --desc="Security Operations"
ipa group-add security_dev --desc="Security Development"
ipa group-add-member security --groups=security_ops --groups=security_dev
# Define Operations groups
ipa group-add security_ops_oper --desc="Security Operations - Operators"
echo $1 | ipa user-add happyhacker --first=Happy --last=Hacker --email=happyhacker@provider.test --user-auth-type='password' --password
ipa group-add-member security_ops_oper --user=happyhacker
#
ipa group-add security_ops_spec --desc="Security Operations - Specialists"
echo $1 | ipa user-add whitehat --first=Hat --last=White --email=whitehat@provider.test --user-auth-type='password' --password
ipa group-add-member security_ops_spec --user=whitehat
# Link Operations groups
ipa group-add-member security_ops --groups=security_ops_oper --groups=security_ops_spec
# Define Dev groups
ipa group-add security_dev_design --desc="Security Designer"
echo $1 | ipa user-add blackhat --first=Hat --last=Black --email=blackhat@provider.test --user-auth-type='password' --password
ipa group-add-member security_dev_design --user=blackhat
#
ipa group-add-member security_dev --groups=security_dev_design

ipa group-add field_services --desc="Field Services"
# Define Operations groups
ipa group-add field_services_eng --desc="Field Service Engineers"
echo $1 | ipa user-add mechanicjoe --first=Joe --last=Mechanic --email=mechanicjoe@provider.test --user-auth-type='password' --password
ipa group-add-member field_services_eng --user=mechanicjoe
#
ipa group-add field_services_floor_management --desc="Field Services Floor Management"
echo $1 | ipa user-add patchhero --first=Patch --last=Hero --email=patchhero@provider.test --user-auth-type='password' --password
ipa group-add-member field_services_floor_management --user=patchhero
# Link Operations groups
ipa group-add-member field_services --groups=field_services_eng --groups=field_services_floor_management

#Add DNS zones
ipa dnszone-add internal.provider.test
ipa dnszone-add services.provider.test
ipa dnszone-add tooling.provider.test
ipa dnszone-add monitoring.provider.test
ipa dnszone-add delivery.provider.test

# Add hosts
addHost "cicdtoolbox-db" "internal" "172.16.9.2"
addHost "restportal" "services" "172.16.10.2"
addHost "portal" "services" "172.16.10.3"
addHost "keycloak" "services" "172.16.10.11"
addHost "freeipa" "services" "172.16.10.12"
addHost "gitea" "tooling" "172.16.11.3"
addHost "jenkins" "tooling" "172.16.11.8"
addHost "nexus" "tooling" "172.16.11.9"
addHost "build-dev" "delivery" "172.16.12.2"
addHost "build-test" "delivery" "172.16.12.3"
addHost "build-acc" "delivery" "172.16.12.4"
addHost "build-prod" "delivery" "172.16.12.5"
addHost "portainer" "monitoring" "172.16.13.4"
addHost "loki" "monitoring" "172.16.13.5"
addHost "promtail" "monitoring" "172.16.13.6"
addHost "grafana" "monitoring" "172.16.13.7"
