FROM postgres:latest
COPY --chmod=0600 --chown=postgres:postgres docker-entrypoint-initdb-resources/server.key /var/lib/postgresql/server.key
COPY --chmod=0644 --chown=postgres:postgres docker-entrypoint-initdb-resources/server.crt /var/lib/postgresql/server.crt
COPY --chmod=0600 docker-entrypoint-initdb-resources/root.crt /var/lib/postgresql/root.crt
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf
#RUN update-ca-certificates

COPY create-multiple-postgresql-databases.sh /docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh 
healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 10s
    timeout: 5s
    retries: 5