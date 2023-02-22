FROM jboss/keycloak:latest

USER root
RUN mkdir /etc/x509
RUN mkdir /etc/x509/https
RUN chmod 777 /etc/x509/https
COPY ca.crt /etc/pki/ca-trust/source/anchors/ca.crt
RUN update-ca-trust
USER 1000

COPY create-realm.sh /opt/jboss/keycloak/bin/create-realm.sh
COPY img/keycloak-bg.png /opt/jboss/keycloak/themes/keycloak/login/resources/img/keycloak-bg.png
COPY img/bg.png /opt/jboss/keycloak/themes/keycloak/welcome/resources/bg.png

EXPOSE 8080
EXPOSE 8443
EXPOSE 8190

HEALTHCHECK:
    TEST: 'curl --insecure --head --fail -s https://localhost:8443 || exit 1'
    INTERVAL: 1m30s
    TIMEOUT: 10s
    RETRIES: 3