FROM grafana/grafana:latest

USER root
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
COPY --chmod=0644 grafana.monitoring.provider.test.pem /etc/ssl/grafana.monitoring.provider.test.pem
COPY --chmod=0600 grafana.monitoring.provider.test.key /etc/ssl/grafana.monitoring.provider.test.key
COPY grafana.ini /etc/grafana/grafana.ini
RUN update-ca-certificates
USER 472

HEALTHCHECK:
    TEST: 'curl --insecure --head --fail -s https://localhost:3000 || exit 1'
    INTERVAL: 1m30s
    TIMEOUT: 10s
    RETRIES: 3