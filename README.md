DepShield: [![DepShield Badge](https://depshield.sonatype.org/badges/Devoteam/NetCICD-developer-toolbox/depshield.svg)](https://depshield.github.io)

# Background
When working on NetCICD, again and again, tools used changed their way of use. In addition, additional functionality was needed: some sort of SSO, Jupyter Notebook, Node Red, git, etc. Adding more tools made the tool chain more brittle every time. And what was worse: building it using VM ate CPU and memory, basically limiting the size of the simulations that can be done. In short: having a dependable pipeline is one complex thing, making sure it keeps on working is another.

With the amazing team of DevOps specialists at Devoteam, we started to develop a basic devops toolchain, containing most things you might need to get started on the click of a button. It is pre-configured and can be used to jumpstart a NetCICD project and based upon Docker to minimise the footprint on a local machine. 

Tooling only has to make your life easier, after all Tech is for People, not the other way around. This is the place where we do this. We are far from finished. Feel free to contribute.

# Want we want to achieve
Having a well functioning tool chain can save a lot of time. But automation is also the fastest way to destroy your business. That is why we want to build a setup that is predictable and reliable:

![toolchain](toolchain.png)

As you can see, the tool chain is separated from the managed environments. This allows to use a single toolset for all environments. 

In every environment you'll see a jump host. This jump host is the only system that can connect back to the tool chain. It is controlled from Jenkins.

By default, a setup that links to a local [CML Personal edition](https://learningnetworkstore.cisco.com/cisco-modeling-labs-personal/cisco-cml-personal) is included, the Netcicd Pipeline. if CML is installed on the same machine as the toolbox is installed upon, Jenkins starts a lab and configures the nodes of the first stage.

For more information on the systems used and the setup of the individual systems, look at the wiki.

# How to install
### Work in progress!!
Even though we try to make this work as well as we can, it is being improved daily. Master should work, Develop is the most complete.
## Installation
The setup has been developed and tested on Ubuntu 20.04 25 GB disk, 2 CPU, 4 GB memory on KVM with Internet access. As the setup also uses local networking, using the Ubuntu Desktop version is easier. During install testing the minimal install is used. 

As the last part of the install uses Robotframework with Selenium, it requires a decent screen resolution. Make sure you have at least 1200 pixels in height, otherwise the finalize install script may fail.

After install, execute:

```sudo apt-get update ```

```sudo apt -y install openjdk-8-jre-headless maven git docker.io curl python3 python3-pip python-is-python3```

```sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose```

```sudo usermod -aG docker ${USER}```

```su - ${USER}```

```sudo chmod +x /usr/local/bin/docker-compose```

```sudo python3 -m pip install robotframework```

```sudo python3 -m pip install robotframework-selenium2library```

```git clone https://github.com/Devoteam/NetCICD-developer-toolbox.git```

```cd NetCICD-developer-toolbox/```

Now the script will run all the way until the end, but it does succeed in running the Robot script (FAIL). This is due to the current shell. Close the current terminal.

Open a new terminal and enter:

```cd NetCICD-developer-toolbox/```

```robot -d install_log/ finalize_install.robot```

Now everything should PASS.

### As Docker has a pull rate limit, you need to authenticate first:
```docker login -u <yourusername> -p <yourpassword>```

After this, you can run:

```./runonce.sh ```

This installs:
* Git
* Docker
* Docker-compose
* openjdk8-jre (sudo apt install openjdk-8-jre-headless)
* maven
* curl

You need to be able to run docker as non-root. See [here](https://docs.docker.com/engine/install/linux-postinstall/) for details.
### Do NOT run this script after use.
* The script stops all existing containers
* It wipes all working directories, networks, containers and builds
* Networks are preconfigured to enable the connect-back from CML
* Running or starting twice will create failing networks and/or containers, duplicate IP addresses and all kinds of other mayhem.
#### License ###
This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
#### Copyright ####
(c) Mark Sibering

