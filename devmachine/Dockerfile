FROM debian:buster-slim

LABEL authors https://www.oda-alexandre.com

ENV USER vscode
ENV HOME /home/${USER}

RUN echo -e '\033[36;1m ******* INSTALL PREREQUISITES ******** \033[0m' && \
  apt-get update && apt-get install -y \
  sudo \
  ca-certificates \
  gnupg \
  git \
  curl \
  wget \
  python3-pip \
  libgtk-3-dev \
  libasound2 \
  libx11-xcb1 \
  libxcb-dri3-0 \
  libdrm2 \
  libgbm1
  
RUN echo -e '\033[36;1m ******* ADD USER ******** \033[0m' && \
  useradd -d ${HOME} -m ${USER} && \
  passwd -d ${USER} && \
  adduser ${USER} sudo

RUN echo -e '\033[36;1m ******* SELECT USER ******** \033[0m'
USER ${USER}

RUN echo -e '\033[36;1m ******* SELECT WORKING SPACE ******** \033[0m'
WORKDIR ${HOME}

RUN echo -e '\033[36;1m ******* INSTALL VSCODE ******** \033[0m' && \
  wget -O /tmp/vsc.deb https://go.microsoft.com/fwlink/?LinkID=760868 && \
  sudo apt install -y /tmp/vsc.deb && \
  rm -f /tmp/vsc.deb

RUN echo -e '\033[36;1m ******* INSTALL POWERSHELL ******** \033[0m' && \
  echo 'deb https://packages.microsoft.com/repos/microsoft-debian-buster-prod buster main' | sudo tee -a /etc/apt/sources.list.d/powershell.list && \
  sudo apt-get update && sudo apt-get install -y \
  powershell

RUN echo -e '\033[36;1m ******* INSTALL DOCKER ******** \033[0m' && \
  curl -fsSL https://get.docker.com -o get-docker.sh && \
  sudo sh get-docker.sh

RUN echo -e '\033[36;1m ******* ADD USER TO GROUP DOCKER ******** \033[0m' && \
  sudo usermod -a -G docker $USER

RUN echo -e '\033[36;1m ******* CONTAINER START COMMAND ******** \033[0m'
CMD /usr/share/code/code
