From hub.oepkgs.net/oepkgs/openeuler-base:openEuler-24.03-LTS-riscv64

RUN dnf makecache \
    && dnf install -y dnf-plugins-core \
    && yum-config-manager --add-repo https://eulermaker.compass-ci.openeuler.openatom.cn/api/ems5/repositories/Ouuleilei:openEuler-24.09:everything/openEuler%3A24.09/riscv64/ \
    && dnf makecache \
    && dnf install --nogpgcheck -y oemaker \
    && dnf clean all 
