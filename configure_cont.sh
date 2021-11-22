#! /bin/bash

#dnf update -y;

dnf install -y podman golang wget;

dnf module list cri-o;
VERSION=1.20;
dnf module enable cri-o:$VERSION;
dnf install -y cri-o;
systemctl enable crio.service --now;

cat <<EOF | tee /etc/cni/net.d/100-crio-bridge.conf
{
    "cniVersion": "0.4.0",
    "name": "crio",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "hairpinMode": true,
    "ipam": {
        "type": "host-local",
        "routes": [
            { "dst": "0.0.0.0/0" }
        ],
        "ranges": [
            [{ "subnet": "10.42.0.0/24" }]
        ]
    }
}
EOF

VERSION="v1.22.0";
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz;
tar -xvf crictl-$VERSION-linux-amd64.tar.gz;
ls -ls;
sudo mv ./crictl /usr/local/bin;
#rm -f crictl-$VERSION-linux-amd64.tar.gz;

cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: "unix:///var/run/crio/crio.sock"
image-endpoint: "unix:///var/run/crio/crio.sock"
timeout: 0
debug: false
pull-image-on-create: true
disable-pull-on-run: false
EOF


cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubectl;
yum install jq;



#### Configuring selinux

sudo dnf -y install container-selinux;
sudo dnf -y install selinux-policy-devel;
curl -L -o /tmp/microshift.fc https://raw.githubusercontent.com/redhat-et/microshift/main/packaging/selinux/microshift.fc;
curl -L -o /tmp/microshift.te https://raw.githubusercontent.com/redhat-et/microshift/main/packaging/selinux/microshift.te;
make -f /usr/share/selinux/devel/Makefile -C /tmp;
sudo dnf -y remove selinux-policy-devel;
sudo mkdir -p /var/run/flannel;
sudo mkdir -p /var/run/kubelet;
sudo mkdir -p /var/lib/kubelet/pods;
sudo mkdir -p /var/run/secrets/kubernetes.io/serviceaccount;
sudo mkdir -p /var/hpvolumes;
sudo semodule -i /tmp/microshift.pp;
sudo restorecon -v /var/hpvolumes;
sudo restorecon -vR /var/lib/kubelet/pods;
