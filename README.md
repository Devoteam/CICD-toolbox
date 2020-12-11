[![DepShield Badge](https://depshield.sonatype.org/badges/owner/repository/depshield.svg)](https://depshield.github.io)
# Background
When working on NetCICD, again and again, tools used changed their way of use. In addition, additional functionality was needed: some sort of SSO, Jupyter Notebook, Node Red, git, etc. Adding more tools made the tool chain more brittle every time. And what was worse: building it using VM ate CPU and memory, basically limiting the size of the simulations that can be done. In short: having a dependable pipeline is one complex thing, making sure it keeps on working is another.

With the amazing team of DevOps specialists at Devoteam, we started to develop a basic devops toolchain, containing most things you might need to get started on the click of a button. It is pre-configured and can be used to jumpstart a NetCICD project and based upon Docker to minimise the footprint on a local machine. 

Tooling only has to make your life easier, after all Tech is for People, not the other way around. This is the place where we do this. We are far from finished. Feel free to contribute.

# Want we want to achieve
Having a well functioning tool chain can save a lot of time. But automation is also the fastest way to destroy your business. That is why we want to build a setup that is predictable and reliable:

![toolchain](toolchain.png)

As you can see, the tool chain is separated from the managed environments. This allows to use a single toolset for all environments. 

In every environment you'll see a jump host. This jump host is the only system that can connect back to the tool chain. It is controlled from Jenkins.

For more information on the systems used and the setup of the individual systems, look at the wiki.

# How to install
### Work in progress!!
Even though we try to make this work as well as we can, it is being improved daily. Master should work, Develop is the most complete.
## Prerequisites
The setup has been developed and tested on Ubuntu 20.04.
You need to have installed:
* Git
* Docker
* openjdk8-jre (sudo apt install openjdk-8-jre-headless)

You need to be able to run docker as non-root. See [here](https://docs.docker.com/engine/install/linux-postinstall/) for details.
## Installation
You can install the toolbox as follows:

```git clone https://github.com/Devoteam/NetCICD-developer-toolbox.git```  
```cd NetCICD-developer-toolbox```  
```./runonce.sh```

### Do NOT run this script after use.
* The script stops all existing containers
* It wipes all working directories, networks, containers and builds
* Networks are preconfigured to enable the connect-back from CML
* Running or starting twice will create failing networks and/or containers, duplicate IP addresses and all kinds of other mayhem.
