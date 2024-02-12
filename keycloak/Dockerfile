FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
COPY ca.crt /etc/pki/ca-trust/source/anchors/mycertificate.crt
RUN update-ca-trust

FROM quay.io/keycloak/keycloak:latest
COPY --from=ubi-micro-build /etc/pki /etc/pki
COPY create-realm.sh /opt/keycloak/bin/create-realm.sh
#COPY img/keycloak-bg.png /opt/keycloak/themes/keycloak/login/resources/img/keycloak-bg.png
#COPY img/bg.png /opt/keycloak/themes/keycloak/welcome/resources/bg.png

EXPOSE 8080
EXPOSE 8443
EXPOSE 8190
