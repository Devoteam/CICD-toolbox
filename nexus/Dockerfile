# pulling offical image
FROM sonatype/nexus3:3.34.0

COPY nexus.properties nexus-data/etc/nexus.properties
COPY *.kar /opt/sonatype/nexus/deploy/ 
COPY nexus.yaml /opt/nexus.yaml
COPY keycloak-nexus.json /opt/sonatype/nexus/etc/keycloak.json