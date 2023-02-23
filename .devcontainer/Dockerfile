FROM ubuntu:focal

RUN sudo apt-get update && sudo apt-get upgrade -y
RUN sudo apt -y install openjdk-11-jre-headless maven git docker.io curl python3 python3-pip python-is-python3
RUN sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN sudo usermod -aG docker ${USER}
RUN sudo su - ${USER}
RUN sudo chmod +x /usr/local/bin/docker-compose
RUN sudo python3 -m pip install robotframework
RUN sudo python3 -m pip install robotframework-selenium2library
RUN echo "export COMPOSE_DOCKER_CLI_BUILD=1" >> ~/.bashrc

RUN sudo apt-get install wget apt-transport-https gnupg lsb-release
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
RUN echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
RUN sudo apt-get update
RUN sudo apt-get install trivy

RUN git clone https://github.com/Devoteam/CICD-toolbox.git
RUN cd CICD-toolbox/
RUN sudo cp geckodriver /usr/local/bin/
