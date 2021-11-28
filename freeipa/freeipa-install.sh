#!/bin/bash 

kinit admin

ipa service-add HTTP/gitea.tooling.test
ipa-getkeytab -p HTTP/gitea.tooling.test -s freeipa.tooling.test -k /etc/krb5-gitea.keytab
chown root /etc/krb5-gitea.keytab
# chgrp jboss /etc/krb5-gitea.keytab
chmod 640 /etc/krb5-gitea.keytab

ipa service-add HTTP/jenkins.tooling.test
ipa-getkeytab -p HTTP/jenkins.tooling.test -s freeipa.tooling.test -k /etc/krb5-jenkins.keytab
chown root /etc/krb5-jenkins.keytab
# chgrp jboss /etc/krb5-jenkins.keytab
chmod 640 /etc/krb5-jenkins.keytab

ipa service-add HTTP/nexus.tooling.test
ipa-getkeytab -p HTTP/nexus.tooling.test -s freeipa.tooling.test -k /etc/krb5-nexus.keytab
chown root /etc/krb5-nexus.keytab
# chgrp jboss /etc/krb5-nexus.keytab
chmod 640 /etc/krb5-nexus.keytab

ipa service-add HTTP/keycloak.tooling.test
ipa-getkeytab -p HTTP/keycloak.tooling.test -s freeipa.tooling.test -k /etc/krb5-keycloak.keytab
chown root /etc/krb5-keycloak.keytab
# chgrp jboss /etc/krb5-keycloak.keytab
chmod 640 /etc/krb5-keycloak.keytab

ipa service-add HTTP/portainer.tooling.test
ipa-getkeytab -p HTTP/portainer.tooling.test -s freeipa.tooling.test -k /etc/krb5-portainer.keytab
chown root /etc/krb5-portainer.keytab
# chgrp jboss /etc/krb5-portainer.keytab
chmod 640 /etc/krb5-portainer.keytab

ipa service-add HTTP/cml.tooling.test
ipa-getkeytab -p HTTP/cml.tooling.test -s freeipa.tooling.test -k /etc/krb5-cml.keytab
chown root /etc/krb5-cml.keytab
# chgrp jboss /etc/krb5-cml.keytab
chmod 640 /etc/krb5-cml.keytab
