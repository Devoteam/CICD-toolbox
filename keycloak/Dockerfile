FROM jboss/keycloak:latest

# USER root
# RUN chmod 777 /var/cache/yum 
# RUN touch /var/cache/yum/metadata
# RUN touch /etc/dnf/dnf.conf
# RUN microdnf update -y && microdnf install -y ipa-client && microdnf clean all
# RUN chmod 755 /var/cache/yum 

#USER 1000

COPY create-realm.sh /opt/jboss/keycloak/bin/create-realm.sh
COPY img/keycloak-bg.png /opt/jboss/keycloak/themes/keycloak/login/resources/img/keycloak-bg.png
COPY img/bg.png /opt/jboss/keycloak/themes/keycloak/welcome/resources/bg.png
COPY keycloak.jks /opt/jboss/keycloak/standalone/configuration/keycloak.jks

EXPOSE 8080
EXPOSE 8443
EXPOSE 8190
