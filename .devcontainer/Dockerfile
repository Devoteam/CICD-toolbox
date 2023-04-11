
ARG  UBUNTU_VERSION=20.04
FROM ubuntu:$UBUNTU_VERSION

RUN apt update && apt install -y openjdk-11-jdk 
RUN apt install -y wget maven git curl ca-certificates firefox ansible python3-pip python-is-python3 apt-transport-https gnupg2 gnupg-agent lsb-release software-properties-common docker.io
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install robotframework robotframework-selenium2library

RUN curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
RUN echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list
RUN apt-get update
RUN apt-get install trivy vault

RUN adduser developer 
RUN echo developer:developer | chpasswd
RUN usermod -aG docker developer
RUN chown developer:developer /home/developer
USER developer
RUN pwd 
RUN git clone https://github.com/Devoteam/CICD-toolbox.git /home/developer/CICD-toolbox
RUN cd /home/developer/CICD-toolbox
USER root
RUN cp /home/developer/CICD-toolbox/geckodriver /usr/local/bin/
# USER developer
# RUN cd /home/developer/CICD-toolbox
# RUN /home/developer/CICD-toolbox/runonce.sh
