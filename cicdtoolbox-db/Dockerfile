FROM postgres:latest

COPY --chmod=0600 --chown=postgres:postgres cicdtoolbox-db.tooling.test.key /var/lib/postgresql/server.key
COPY --chmod=0644 --chown=postgres:postgres cicdtoolbox-db.tooling.test.pem /var/lib/postgresql/server.crt
COPY --chmod=0600 ca.crt /usr/local/share/ca-certificates/ca.crt
#RUN update-ca-certificates

COPY create-multiple-postgresql-databases.sh /docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh 
