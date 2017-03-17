# Copyright (c) 2012-2017 Red Hat, Inc
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM registry.centos.org/centos/centos

MAINTAINER Clement Escoffier

ARG JAVA_VERSION=1.8.0
ARG SWARM_VERSION=2017.3.2

# ENV VERTX_GROUPID=io.vertx \
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION} \
    M2_HOME=/opt/rh/rh-maven33/root/usr/share/maven

RUN yum -y update && \
    yum -y install wget sudo openssh-server centos-release-scl && \
    yum -y install rh-maven33 java-${JAVA_VERSION}-openjdk-devel && \
    yum clean all && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    # sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    useradd -u 1000 -G users,wheel -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user

COPY install-swarm-dependencies.sh /tmp/
RUN chown user:user /tmp/install-swarm-dependencies.sh && \
chmod a+x /tmp/install-swarm-dependencies.sh
USER user

RUN scl enable rh-maven33 /tmp/install-swarm-dependencies.sh && \
    sudo rm -f /tmp/install-swarm-dependencies.sh

EXPOSE 8080

CMD tail -f /dev/null
