From hub.oepkgs.net/oepkgs/openeuler-base:openEuler-24.03-LTS-riscv64

RUN dnf makecache \
    && dnf install -y dnf-plugins-core \
    && yum-config-manager --add-repo https://eulermaker.compass-ci.openeuler.openatom.cn/api/ems5/repositories/openEuler-24.09:everything/openEuler%3A24.09/riscv64/history/dc15db38-7822-11ef-b56f-f62ccec4c5fe/last/ \
    &&  echo "gpgcheck=0" >> /etc/yum.repos.d/eulermaker.compass-ci.openeuler.openatom.cn_api_ems5_repositories_openEuler-24.09_everything_openEuler3A24.09_riscv64_history_dc15db38-7822-11ef-b56f-f62ccec4c5fe_last_.repo \ 
    && dnf install -y oemaker \
    && dnf clean all 
