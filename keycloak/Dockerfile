FROM jboss/keycloak:latest

USER root
RUN mkdir /etc/x509
RUN mkdir /etc/x509/https
RUN chmod 777 /etc/x509/https

USER 1000

COPY create-realm.sh /opt/jboss/keycloak/bin/create-realm.sh
COPY img/keycloak-bg.png /opt/jboss/keycloak/themes/keycloak/login/resources/img/keycloak-bg.png
COPY img/bg.png /opt/jboss/keycloak/themes/keycloak/welcome/resources/bg.png

EXPOSE 8080
EXPOSE 8443
EXPOSE 8190
