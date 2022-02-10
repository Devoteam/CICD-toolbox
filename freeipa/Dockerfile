FROM freeipa/freeipa-server:centos-8-stream

COPY freeipa-install.sh /root/freeipa-install.sh
ADD certs/*.csr /tmp/certs/
COPY pki.conf /etc/pki/pki.conf