#!/usr/bin/bash
KUBE_VERSION="v1.29.1"
PAUSE_VERSION="v3.9"
ETCD_VERSION="3.5.10-0"
COREDNS_VERSION="1.11.1"
BASE_IMAGE="hub.oepkgs.net/oepkgs/openeuler-base:openEuler-24.03-LTS-riscv64"
HUB_REPO_NAME="hub.oepkgs.net/ruoqing"

KUBE_REPO="
[KUBE]
name=KUBE
baseurl=https://build-repo.tarsier-infra.isrc.ac.cn/home:/heruoqing:/branches:/openEuler:/24.03:/Epol/mainline_riscv64/
enabled=1
gpgcheck=0
gpgkey=http://repo.openeuler.org/openEuler-24.03-LTS/OS//RPM-GPG-KEY-openEuler
"

BASE_DOCKERFILE="
FROM $BASE_IMAGE

COPY kube.repo /etc/yum.repos.d/kube.repo

RUN dnf update && dnf install -y kubernetes-master kubernetes-node etcd coredns \
                    wget gcc
"

KUBE_DOCKERFILE="
FROM ${HUB_REPO_NAME}/oe-build-base AS builder

FROM $BASE_IMAGE

ARG BIN
COPY --from=builder /usr/bin/\$BIN /usr/local/bin/\$BIN
"

PROXY_DOCKERFILE="
FROM ${HUB_REPO_NAME}/oe-build-base AS builder

FROM $BASE_IMAGE

RUN dnf update && \
    dnf install -y conntrack-tools \
        ebtables \
        ipset \
        iptables \
        kmod

ARG BIN
COPY --from=builder /usr/bin/\$BIN /usr/local/bin/\$BIN
"

ETCD_DOCKERFILE="
FROM ${HUB_REPO_NAME}/oe-build-base AS builder

FROM $BASE_IMAGE

COPY --from=builder /usr/bin/etcd /usr/local/bin/etcd
COPY --from=builder /usr/bin/etcdctl /usr/local/bin/etcdctl

RUN mkdir -p /var/etcd/ && \
    mkdir -p /var/lib/etcd/

EXPOSE 2379 2380
CMD ["/usr/local/bin/etcd"]
"

COREDNS_DOCKERFILE="
FROM ${HUB_REPO_NAME}/oe-build-base AS builder

FROM scratch

COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /usr/sbin/coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
"

PAUSE_DOCKERFILE="
FROM ${HUB_REPO_NAME}/oe-build-base AS builder

RUN wget https://raw.githubusercontent.com/kubernetes/kubernetes/${KUBE_VERSION}/build/pause/linux/pause.c && \\
    gcc -Os -Wall -Werror -static -DVERSION=${PAUSE_VERSION}-${KUBE_VERSION} -o pause pause.c

FROM scratch

COPY --from=builder /pause /pause

USER 65535:65535
ENTRYPOINT ["/pause"]
"

function generate {
    local type=$1
    local arr=($2)
    local file_name=$3
    local version=$4

    echo $type

cat > Dockerfile.$type << EOF
${!file_name}
EOF

    if [ $NEED_PUSH ]; then
        local builder="docker buildx build --push"
    else
        local builder="docker buildx build"
    fi

    for bin in ${arr[*]}; do
         $builder -t $HUB_REPO_NAME/$bin:$version --build-arg=BIN=$bin -f Dockerfile.$type .
    done
}

# set workdir
[ -d tmp/ ] || mkdir tmp
pushd tmp

# Build Base Image
cat >kube.repo <<EOF
$KUBE_REPO
EOF

generate base oe-build-base BASE_DOCKERFILE latest

kube_list=(kube-apiserver kube-scheduler kube-controller-manager)

generate kube "${kube_list[*]}" KUBE_DOCKERFILE $KUBE_VERSION

generate proxy kube-proxy PROXY_DOCKERFILE $KUBE_VERSION

generate etcd etcd ETCD_DOCKERFILE $ETCD_VERSION

generate coredns coredns COREDNS_DOCKERFILE $COREDNS_VERSION

generate pause pause PAUSE_DOCKERFILE $PAUSE_VERSION

popd
rm -rf tmp
