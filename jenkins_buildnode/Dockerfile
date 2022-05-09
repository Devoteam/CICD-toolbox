FROM ciscotestautomation/pyats:latest-alpine

ENV JAVA_HOME "/usr"

RUN apk add --update \
    openjdk8 \
    git \
    openssh \
    openssh-keygen \
    openssl \
    libxml2-dev \
    libxslt-dev \
    sshpass
RUN pip3 install --upgrade pip
RUN apk --update add --virtual \
        .build-deps \
        gcc \
        libffi-dev \
        openssl-dev \
        build-base \
 && pip3 install --upgrade \
        cffi \
        ncclient \
        behave\
        virlutils\
 && pip3 install \
        ansible \
 && apk del \
        .build-deps \
 && rm -rf /var/cache/apk/*

RUN echo -e """\
\n\
Host *\n\
    PasswordAuthentication yes\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config

RUN echo "export JAVA_HOME=/usr" >> /etc/profile
 
RUN adduser -D jenkins && (echo "jenkins:jenkins" | chpasswd) && (echo "root:root" | chpasswd)
COPY agent.jar /home/jenkins/
RUN echo "[defaults]" > /home/jenkins/.ansible.cfg
RUN echo "host_key_checking = False" >> /home/jenkins/.ansible.cfg
RUN chown jenkins:jenkins /home/jenkins/.ansible.cfg
RUN chown -R jenkins:jenkins /home/jenkins

COPY agent.jar /root/
RUN echo "[defaults]" > /root/.ansible.cfg
RUN echo "host_key_checking = False" >> /root/.ansible.cfg
RUN ln -s /usr/bin/python3 /usr/bin/python

ADD docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
EXPOSE 22 
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
