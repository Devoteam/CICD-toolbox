FROM netarch/netcicd:netcicd-3.0

USER root
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates
USER 10001
