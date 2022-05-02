FROM grafana/promtail:2.5.0

USER root
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates
USER 10001

COPY config.yml /etc/promtail/config.yml
