FROM ciscotestautomation/pyats:latest-alpine

ENV JAVA_HOME "/usr"
RUN apk add --update --no-cache \
    openjdk11 \
    git \
    openssh \
    openssh-keygen \
    openssl \
    libxml2-dev \
    libxslt-dev \
    sshpass \
    curl \
    bash \
    docker \
    docker-compose \
    terraform
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
        robotframework \
        azure-cli \
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
RUN echo "[defaults]" > /home/jenkins/.ansible.cfg
RUN echo "host_key_checking = False" >> /home/jenkins/.ansible.cfg
RUN chown jenkins:jenkins /home/jenkins/.ansible.cfg
RUN chown -R jenkins:jenkins /home/jenkins
RUN addgroup jenkins docker

COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
COPY agent.jar /home/jenkins/
COPY ca.crt /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates
COPY cacerts /etc/ssl/certs/java/cacerts

USER jenkins
WORKDIR /home/jenkins
RUN curl -fsSL https://raw.githubusercontent.com/dikhan/terraform-provider-openapi/master/scripts/install.sh | bash -s -- --provider-name "onprem" --provider-source-address "restportal.services.provider.test/datacenter"
COPY terraform-provider-openapi.yaml /home/jenkins/.terraform.d/plugins/terraform-provider-openapi.yaml
COPY onprem.yaml /home/jenkins/onprem.yaml


USER root
CMD ["/usr/sbin/sshd", "-D"]
COPY rc.local /etc/rc.local
EXPOSE 22 

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
