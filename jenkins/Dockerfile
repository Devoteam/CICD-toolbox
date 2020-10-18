FROM jenkins/jenkins:lts

LABEL maintainer="thomas@thinkcode.se"
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

ENV JENKINS_HOME /var/jenkins_home

ARG JAVA_OPTS
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"
RUN rm -rf /usr/share/jenkins/ref/plugins/Plugin.lock
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
