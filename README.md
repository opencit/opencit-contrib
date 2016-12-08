#Open Cloud Integrity Technology

CONTRIBUTIONS
=============

Assorted patches to open source projects that are pending contribution
to the upstream repositories.

For each project, the original source code is kept in archive (.tgz) 
format on a Maven repository. It is downloaded, unpacked, patched, and 
compiled by the build script. 

Only the build script and patches are in source control. 


HOW TO BUILD THE PROJECT
========================

# Pre-requisites

You must have the following tools installed:
  
* jdk 7
* ant 1.9
* maven 3.3
* make 4.1
* gcc 5.4
* g++ 5.4
* unzip 6.0

Also, the following directories must be created and writable to the
non-root user which is building the code:

* /opt/mtwilson/share/hex2bin
* /opt/mtwilson/share/openssl
* /opt/mtwilson/share/trousers
* /opt/mtwilson/share/tpmquote
* /opt/mtwilson/share/tpmtools
* /opt/mtwilson/share/niarl

Easy way to do it (replace `jenkins` with your non-root username):

    mkdir -p /opt/mtwilson
    chown -R jenkins:jenkins /opt/mtwilson

Ensure you have the following environment variables set, with correct
values of ANT_HOME and MAVEN_HOME for your system:

    export LINUX_TARGET=generic
    export ANT_HOME=/usr/share/apache-ant-1.9.7
    export MAVEN_HOME=/usr/share/apache-maven-3.3.9
    export PATH=$ANT_HOME/bin:$MAVEN_HOME/bin:$PATH

# Automated build

To build the project, run this command:

    ant

More options:

  * Run "ant ready" to ensure you have all pre-requisites to build
  * Run "ant" or "ant build" to build the entire project
  * Run "ant ready build packages" to clean build and generate packages
  * Run "ant build packages" to rebuild only and generate packages
  * Run "ant packages" to generate packages (requires prior build)

# Included:

* TPM Tools v 1.3.8: Was modified to support additional parameters. The source code can be obtained through [Sourceforge](https://sourceforge.net/projects/trousers/files/tpm-tools/1.3.8)

