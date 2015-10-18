FROM centos:centos6.7

MAINTAINER Bill W

ENV REFRESHED_AT 20151018

ENV JAVA_VERSION=1.7.0
ENV RUNDECK_VERSION=2.6.0-1.11.GA

# Install puppet
RUN rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
RUN yum -y update && \
    yum -y install puppet hiera facter 

# Install java and rundeck 
RUN puppet resource package puppet ensure=latest
RUN puppet resource package facter ensure=latest
RUN puppet resource package hiera  ensure=latest
RUN puppet resource package wget   ensure=latest
RUN puppet resource package java-${JAVA_VERSION}-openjdk ensure=latest
RUN puppet resource yumrepo bintray-rundeck baseurl='http://dl.bintray.com/rundeck/rundeck-rpm/' descr='bintray rundeck repo' enabled='1' gpgcheck='0' priority='1'
RUN puppet resource package rundeck ensure=${RUNDECK_VERSION}

# Install rundeck aws ec2 node plugin
RUN wget https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/1.5/rundeck-ec2-nodes-plugin-1.5.jar -O /var/lib/rundeck/libext/rundeck-ec2-nodes-plugin-1.5.jar

# Run rundeck
CMD source /etc/rundeck/profile && ${JAVA_HOME:-/usr}/bin/java ${RDECK_JVM} -cp ${BOOTSTRAP_CP} com.dtolabs.rundeck.RunServer /var/lib/rundeck ${RDECK_HTTP_PORT}
