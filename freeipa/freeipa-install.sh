#!/bin/bash 

kinit admin

# Add hosts
ipa host-add --force --ip-address=172.16.11.3 gitea.tooling.test
ipa service-add HTTP/gitea.tooling.test
ipa-getkeytab -p HTTP/gitea.tooling.test -s freeipa.tooling.test -k /etc/krb5-gitea.keytab
chown root /etc/krb5-gitea.keytab
chmod 640 /etc/krb5-gitea.keytab

ipa host-add --force --ip-address=172.16.11.8 jenkins.tooling.test
ipa service-add HTTP/jenkins.tooling.test
ipa-getkeytab -p HTTP/jenkins.tooling.test -s freeipa.tooling.test -k /etc/krb5-jenkins.keytab
chown root /etc/krb5-jenkins.keytab
chmod 640 /etc/krb5-jenkins.keytab

ipa host-add --force --ip-address=172.16.11.9 nexus.tooling.test
ipa service-add HTTP/nexus.tooling.test
ipa-getkeytab -p HTTP/nexus.tooling.test -s freeipa.tooling.test -k /etc/krb5-nexus.keytab
chown root /etc/krb5-nexus.keytab
chmod 640 /etc/krb5-nexus.keytab

ipa host-add --force --ip-address=172.16.11.11 keycloak.tooling.test
ipa service-add HTTP/keycloak.tooling.test
ipa-getkeytab -p HTTP/keycloak.tooling.test -s freeipa.tooling.test -k /etc/krb5-keycloak.keytab
chown root /etc/krb5-keycloak.keytab
chmod 640 /etc/krb5-keycloak.keytab

ipa host-add --force --ip-address=172.16.11.15 portainer.tooling.test
ipa service-add HTTP/portainer.tooling.test
ipa-getkeytab -p HTTP/portainer.tooling.test -s freeipa.tooling.test -k /etc/krb5-portainer.keytab
chown root /etc/krb5-portainer.keytab
chmod 640 /etc/krb5-portainer.keytab

# Add Groups
ipa group-add iam_ops --desc="IAM Operations"
ipa group-add iam_ops_oper --desc="IAM Operations - Operators"
ipa group-add iam_ops_spec --desc="IAM Operations - Specialists"
ipa group-add-member iam_ops --groups=iam_ops_oper --groups=iam_ops_spec
ipa group-add iam_dev --desc="IAM Development"
ipa group-add iam --desc="IAM"
ipa group-add-member iam --groups=iam_ops --groups=iam_dev

ipa group-add office_ops --desc="Office Operations"
ipa group-add office_ops_oper --desc="IAM Operations - Operators"
ipa group-add office_ops_spec --desc="IAM Operations - Specialists"
ipa group-add-member office_ops --groups=office_ops_oper --groups=office_ops_spec
ipa group-add office_dev --desc="Office Development"
ipa group-add office --desc="Office"
ipa group-add-member office --groups=office_ops --groups=office_dev

ipa group-add campus_ops --desc="Campus Operations"
ipa group-add campus_ops_oper --desc="Campus Operations - Operators"
ipa group-add campus_ops_spec --desc="Campus Operations - Specialists"
ipa group-add-member campus_ops --groups=campus_ops_oper --groups=campus_ops_spec
ipa group-add campus_dev --desc="Campus Development"
ipa group-add campus_dev_lan --desc="Campus Development - LAN Designer"
ipa group-add campus_dev_wifi --desc="Campus Development - WIFI designer"
ipa group-add-member campus_ops --groups=campus_dev_lan --groups=campus_dev_wifi
ipa group-add campus --desc="Campus"
ipa group-add-member campus --groups=campus_ops --groups=campus_dev

ipa group-add wan_ops --desc="WAN Operations"
ipa group-add wan_ops_oper --desc="WAN Operations - Operators"
ipa group-add wan_ops_spec --desc="WAN Operations - Specialists"
ipa group-add-member wan_ops --groups=wan_ops_oper --groups=wan_ops_spec
ipa group-add wan_dev --desc="WAN Development"
ipa group-add wan --desc="WAN"
ipa group-add-member wan --groups=wan_ops --groups=wan_dev

ipa group-add dc_ops_compute --desc="Datacenter Compute Operations"
ipa group-add dc_ops_compute_oper --desc="Datacenter Compute Operations - Operators"
ipa group-add dc_ops_compute_spec --desc="Datacenter Compute Operations - Specialists"
ipa group-add-member dc_ops_compute --groups=dc_ops_compute_oper --groups=dc_ops_compute_spec

ipa group-add dc_ops_network --desc="Datacenter Network Operations"
ipa group-add dc_ops_network_oper --desc="Datacenter Network Operations - Operators"
ipa group-add dc_ops_network_spec --desc="Datacenter Network Operations - Specialists"
ipa group-add-member dc_ops_network --groups=dc_ops_network_oper --groups=dc_ops_network_spec

ipa group-add dc_ops_storage --desc="Datacenter Storage Operations"
ipa group-add dc_ops_storage_oper --desc="Datacenter Storage Operations - Operators"
ipa group-add dc_ops_storage_spec --desc="Datacenter Storage Operations - Specialists"
ipa group-add-member dc_ops_storage --groups=dc_ops_storage_oper --groups=dc_ops_storage_spec

ipa group-add dc_ops --desc="Datacenter Operations"
ipa group-add-member dc_ops --groups=dc_ops_compute --groups=dc_ops_network --groups=dc_ops_storage

ipa group-add dc_dev_compute --desc="Datacenter Compute Development"
ipa group-add dc_dev_network --desc="Datacenter Network Development"
ipa group-add dc_dev_storage --desc="Datacenter Storage Development"
ipa group-add dc_dev --desc="Datacenter Development"
ipa group-add-member dc_dev --groups=dc_dev_compute --groups=dc_dev_network --groups=dc_dev_storage

ipa group-add dc --desc="Datacenter"

ipa group-add-member dc --groups=dc_ops --groups=dc_dev

ipa group-add app_ops --desc="Application Operations"
ipa group-add app_ops_oper --desc="Application Operations - Operators"
ipa group-add app_ops_spec --desc="Application Operations - Specialists"
ipa group-add-member app_ops --groups=app_ops_oper --groups=app_ops_spec
ipa group-add app_dev --desc="Application Development"
ipa group-add app --desc="Application"
ipa group-add-member app --groups=app_ops --groups=app_dev

ipa group-add tool_ops --desc="Tooling Operations"
ipa group-add tool_ops_oper --desc="Tooling Operations - Operators"
ipa group-add tool_ops_spec --desc="Tooling Operations - Specialists"
ipa group-add-member tool_ops --groups=tool_ops_oper --groups=tool_ops_spec
ipa group-add tool_dev --desc="Tooling Development"
ipa group-add tool --desc="Tooling"
ipa group-add-member tool --groups=tool_ops --groups=tool_dev

ipa group-add sec_ops --desc="Security Operations"
ipa group-add sec_ops_oper --desc="Security Operations - Operators"
ipa group-add sec_ops_spec --desc="Security Operations - Specialists"
ipa group-add-member sec_ops --groups=sec_ops_oper --groups=sec_ops_spec
ipa group-add sec_dev --desc="Security Development"
ipa group-add sec --desc="Security"
ipa group-add-member sec --groups=sec_ops --groups=sec_dev

ipa group-add fs --desc="Field Services"
ipa group-add fs_fse --desc="Field Service Engineers"
ipa group-add fs_fm --desc="Field Services Floor Management"
ipa group-add-member fs --groups=fs_fse --groups=fs_fm

# Add users
ipa user-add netcicd --first=NetCICD --last=Godmode --email=netcicd@tooling.test
ipa user-add git-jenkins --first=Git --last=Jenkins --email=git-jenkins@tooling.test
ipa user-add jenkins-jenkins --first=Jenkins --last=Jenkins --email=jenkins-jenkins@tooling.test
ipa user-add netcicd-pipeline --first=NetCICD --last=Pipeline --email=netcicd-pipeline@tooling.test
#IAM, Office, Campus, WAN
ipa user-add compudude --first=Compu --last=Dude --email=compudude@tooling.test
ipa group-add-member dc_ops_compute_oper --user=compudude
ipa user-add compuspecialist --first=Compu --last=Specialist --email=compuspecialist@tooling.test
ipa group-add-member dc_ops_compute_spec --user=compuspecialist
ipa user-add compuarchitect --first=Compu --last=Architect --email=compuarchitect@tooling.test
ipa group-add-member dc_dev_compute --user=compuarchitect

ipa user-add netdude --first=Net --last=Dude --email=netdude@tooling.test
ipa group-add-member dc_ops_network_oper --user=netdude
ipa user-add netspecialist --first=Net --last=Specialist --email=netspecialist@tooling.test
ipa group-add-member dc_ops_network_spec --user=netspecialist
ipa user-add netarchitect --first=Net --last=Architect --email=netarchitect@tooling.test
ipa group-add-member dc_dev_network --user=netarchitect

ipa user-add diskdude --first=Disk --last=Dude --email=diskdude@tooling.test
ipa group-add-member dc_ops_storage_oper --user=diskdude
ipa user-add diskspecialist --first=Disk --last=Specialist --email=diskspecialist@tooling.test
ipa group-add-member dc_ops_storage_spec --user=diskspecialist
ipa user-add diskarchitect --first=Disk --last=Architect --email=diskarchitect@tooling.test
ipa group-add-member dc_dev_storage --user=diskarchitect
#app
ipa user-add tooltiger --first=Tool --last=Tiger --email=tooltiger@tooling.test
ipa group-add-member tool_ops_oper --user=tooltiger
ipa user-add toolmaster --first=Tool --last=Master --email=toolmaster@tooling.test
ipa group-add-member tool_ops_spec --user=toolmaster
ipa user-add blacksmith --first=Black --last=Smith --email=blacksmith@tooling.test
ipa group-add-member tool_dev --user=blacksmith

ipa user-add happyhacker --first=Happy --last=Hacker --email=happyhacker@tooling.test
ipa group-add-member sec_ops_oper --user=happyhacker
ipa user-add whitehat --first=Hat --last=White --email=whitehat@tooling.test
ipa group-add-member sec_ops_spec --user=whitehat
ipa user-add blackhat --first=Hat --last=Black --email=blackhat@tooling.test
ipa group-add-member sec_dev --user=blackhat

ipa user-add mechanicjoe --first=Joe --last=Mechanic --email=mechanicjoe@tooling.test
ipa group-add-member fs_fse --user=mechanicjoe
ipa user-add patchhero --first=Patch --last=Hero --email=patchhero@tooling.test
ipa group-add-member fs_fm --user=patchhero

ldapmodify -x -D 'cn=Directory Manager' -w Pa55w0rd -v 
dn: uid=system,cn=sysaccounts,cn=etc,dc=tooling,dc=test
changetype: add
objectclass: account
objectclass: simplesecurityobject
uid: system
userPassword: Pa55w0rd
passwordExpirationTime: 20380119031407Z
nsIdleTimeout: 0
<blank line>
