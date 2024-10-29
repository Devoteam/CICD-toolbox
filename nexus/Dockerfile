# pulling offical image
FROM sonatype/nexus3:3.51.0
USER root
COPY ca.crt /etc/pki/ca-trust/source/anchors/ca.crt
RUN update-ca-trust

USER 200
RUN mkdir /nexus-data/etc
COPY nexus.properties /nexus-data/etc/nexus.properties
COPY *.kar /opt/sonatype/nexus/deploy/ 
COPY nexus.yaml /opt/nexus.yaml
COPY keycloak-nexus.json /opt/sonatype/nexus/etc/keycloak.json
