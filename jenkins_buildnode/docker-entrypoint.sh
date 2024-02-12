#!/bin/sh

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	/usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	/usr/bin/ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

cd /home/jenkins

/usr/bin/dockerd &
/home/jenkins/act_runner register --instance https://gitea.tooling.provider.test:3000 --name $BUILD_ENVIRONMENT --token $RUNNER_TOKEN --no-interactive
/home/jenkins/act_runner daemon >/dev/null 2>&1 &

su jenkins -c 'java -jar agent.jar -jnlpUrl "https://jenkins.tooling.provider.test:8084/computer/'$BUILD_ENVIRONMENT'/jenkins-agent.jnlp" -secret @secret-file.txt -workDir "/home/jenkins" &'

exec "$@"
