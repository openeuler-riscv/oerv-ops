From hub.oepkgs.net/oepkgs/openeuler-base:openEuler-24.03-LTS-riscv64


RUN set -eux; \
    yum install -y python3-pip cpio bsdtar expect openssh sudo vim git strace python-jenkins python3-requests python-concurrent-log-handler python3-gevent python3-marshmallow python3-pyyaml python-pandas python-xlrd python-retrying python-esdk-obs-python git java-11-openjdk dumb-init
RUN ln -s /usr/lib/jvm/java-11-openjdk-11.0.23.9-1.oe2403.riscv64/bin/java /usr/local/openjdk-11

ARG VERSION=4.3
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent

RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/agent.jar \
    && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

RUN curl --create-dirs -fsSLo /usr/local/bin/jenkins-agent http://121.36.53.23/AdoptOpenJDK/jenkins-agent
#COPY jenkins-agent /usr/local/bin/jenkins-agent

RUN chmod a+rx /usr/local/openjdk-11 \
     && chmod a+rx /usr/local/bin/jenkins-agent \
     && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR ${AGENT_WORKDIR}


ENTRYPOINT ["jenkins-agent"]


