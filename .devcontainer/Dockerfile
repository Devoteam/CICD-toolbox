FROM docker:dind

RUN sudo apt update && sudo apt install -y openjdk-11-jdk maven git curl firefox-esr ansible python3-pip python-is-python3 wget apt-transport-https gnupg lsb-release
RUN python3 -m pip install robotframework robotframework-selenium2library

RUN echo "export COMPOSE_DOCKER_CLI_BUILD=1" >> ~/.bashrc

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
RUN echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
RUN sudo apt-get update
RUN sudo apt-get install trivy vault

RUN adduser developer 
RUN echo developer:developer | chpasswd
RUN usermod -aG docker developer
RUN chown developer:developer /home/developer
# USER developer
# RUN pwd 
# RUN git clone https://github.com/Devoteam/CICD-toolbox.git /home/developer/CICD-toolbox
# RUN cd /home/developer/CICD-toolbox
# USER root
# RUN cp /home/developer/CICD-toolbox/geckodriver /usr/local/bin/
#USER developer
#RUN cd /home/developer/CICD-toolbox
#RUN ./runonce
