FROM freeipa/freeipa-server:centos-8-stream

COPY freeipa-install.sh /root/freeipa-install.sh
RUN mkdir /tmp/hostcerts
COPY certs/*.csr /tmp/hostcerts/