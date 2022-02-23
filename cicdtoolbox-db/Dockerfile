FROM postgres:latest

COPY cicdtoolbox-db.tooling.test.key /var/lib/postgresql/data/server.key
COPY cicdtoolbox-db.tooling.test.pem /var/lib/postgresql/data/server.crt
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates

COPY create-multiple-postgresql-databases.sh /docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh 
