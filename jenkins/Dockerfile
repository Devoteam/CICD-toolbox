FROM jenkins/jenkins:lts

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false ${JAVA_OPTS:-}"
ENV CASC_JENKINS_CONFIG /var/jenkins_conf/casc.yaml
ENV JENKINS_OPTS="--httpPort=8084"

COPY --chown=jenkins:jenkins argos.hpi /usr/share/jenkins/ref/plugins/
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY casc.yaml /var/jenkins_conf/casc.yaml
COPY Infraautomator/ /var/jenkins_home/jobs/Infraautomator/

ARG JAVA_OPTS
