FROM grafana/loki:2.5.0

USER root
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates
USER 10001

COPY local-config.yaml /etc/loki/local-config.yaml
