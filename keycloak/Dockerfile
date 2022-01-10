FROM jboss/keycloak:latest

COPY create-realm.sh /opt/jboss/keycloak/bin/create-realm.sh
COPY img/keycloak-bg.png /opt/jboss/keycloak/themes/keycloak/login/resources/img/keycloak-bg.png
COPY img/bg.png /opt/jboss/keycloak/themes/keycloak/welcome/resources/bg.png
COPY keycloak.jks /opt/jboss/keycloak/standalone/configuration/keycloak.jks

EXPOSE 8080
EXPOSE 8443
EXPOSE 8190
