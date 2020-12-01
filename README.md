# Background
When working on NetCICD, again and again, tools I was using changed their way of use. Jenkins for example changed from username/password on the API to token-only, breaking the pipeline. 

In addition, I needed additional functionality: some sort of SSO, Jupyter Notebook, Node Red, git, etc. And adding more tools made the toolchain more brittle every time. And what was worse: building it using VM ate my CPU and memory, basically limiting the size of the simulations I can do in VIRL/CML.

In short: I arrived at the conclusion that having a dependable pipeline is one complex thing, making sure it keeps on working is another. I wanted to solve this once and for all. Not only the network needs a CICD pipeline, but the pipeline in itself too.

I now happen to work with an amazing team of DevOps specialists, so together with them, I started to build a basic toolchain that contains the most important tools pre-configured and which can be used to jumpstart a NetCICD project. It is based upon Docker to minimise the footprint, using docker-compose to set up the stack. This allows to port it to Kubernetes later (running K8S locally adds no value, only eats CPU). 

After all, it is about the network, not the tooling. The tooling only has to make your life easier. If the tooling eats all of your time instead of that what pays the bills, you are working on the wrong thing.

This is the place where we do this. Feel free to contribute.

# Want do I want to achieve
When automating networks as I do, it is clear that having a well working toolchain can save a lot of time, but also introduce a lot of vulnerabilities. That is why I want to build a setup that has a specific setup:

![toolchain](toolchain.png)

As you can see from the setup, the toolchain is separated from the managed environments. This is to enable to use a single toolset for both development and production. This allows you to push setup to git as one user and pick it up as another.
In every environment you'll see a jump host. This jump host is the only system that can connect back to the tooling compartment. It is controlled from Jenkins through ansible playbooks retrieved from git.

For more information on the systems used and the setup of the individual systems, look at the wiki.
