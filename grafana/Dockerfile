FROM grafana/grafana:latest

USER root
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates
USER 472