# pulling offical image
FROM sonatype/nexus3:latest

COPY nexus.properties nexus-data/etc/nexus.properties
COPY *.kar /opt/sonatype/nexus/deploy/ 
COPY nexus.yaml /opt/nexus.yaml
COPY keycloak-nexus.json /opt/sonatype/nexus/etc/keycloak.json