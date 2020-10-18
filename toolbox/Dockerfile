# NetCICD toolbox
#
# inspired by adoztal aaa and adoztal/net_tools

FROM ubuntu:bionic

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y --no-install-recommends \
    install telnet curl openssh-server openssh-client openssl default-jre git sshpass \
    nano vim-tiny iputils-ping build-essential ethtool iputils-ping \
    net-tools freeradius freeradius-utils tacacs+ snmpd snmptrapd rsyslog \
    && rm -rf /var/lib/apt/lists/*

ADD clients.conf /etc/freeradius/3.0/clients.conf
ADD users /etc/freeradius/3.0/mods-config/files/authorize
ADD tac_plus.conf /etc/tacacs+/tac_plus.conf
ADD runonce.sh /sbin/runonce.sh
ADD rsyslog.conf /etc/rsyslog.conf
ADD default_snmptrapd /etc/default/snmptrapd
ADD snmpd.conf /etc/snmp/snmpd.conf
ADD snmptrapd.conf /etc/snmp/snmptrapd.conf

RUN DEBIAN_FRONTEND=noninteractive chmod 755 /sbin/runonce.sh; sleep 1; /sbin/runonce.sh

ADD docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
EXPOSE \
  22/tcp \
  49/tcp \
  161/udp \
  162/udp \
  514/udp \
  1812/udp \
  1813/udp 

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]

