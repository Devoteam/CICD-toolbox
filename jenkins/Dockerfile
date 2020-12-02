FROM jenkins/jenkins:lts

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"
ENV CASC_JENKINS_CONFIG /var/jenkins_conf/casc.yaml

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY casc.yaml /var/jenkins_conf/casc.yaml
COPY NetCICD/ /var/jenkins_home/jobs/NetCICD/
ARG JAVA_OPTS
