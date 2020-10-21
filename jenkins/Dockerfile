FROM jenkins/jenkins:lts

ENV JENKINS_HOME /var/jenkins_home
ENV CASC_JENKINS_CONFIG /var/jenkins_home/jenkins.yaml

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
#COPY jenkins.yml /var/jenkins_home/jenkins.yaml

ARG JAVA_OPTS
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"

RUN rm -rf /usr/share/jenkins/ref/plugins/Plugin.lock
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
