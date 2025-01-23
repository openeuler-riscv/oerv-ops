FROM  hub.oepkgs.net/oerv-ci/openeuler-24.03-lts-sp1-riscv64:latest

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

# set mirror yum repo
RUN sed -i /etc/yum.repos.d/openEuler.repo -e "s@repo.openeuler.org@mirrors.huaweicloud.com/openeuler@g" 

# setup SSH server
RUN dnf makecache \
    && dnf install -y java-17-openjdk openssh-server shadow git sudo \
    && dnf clean all

RUN groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd

RUN echo "PATH=${PATH}" >> /etc/environment
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# from https://github.com/jenkinsci/docker-ssh-agent/blob/master/setup-sshd
COPY setup-sshd /usr/local/bin/setup-sshd    
RUN chmod +x /usr/local/bin/setup-sshd

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

EXPOSE 22

ENTRYPOINT ["setup-sshd"]
