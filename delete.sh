#!/bin/sh
set -e -o pipefail

sudo rm -rf /var/lib/microshift;

sudo systemctl stop microshift; 
sudo crictl stop $(sudo crictl ps -q);
sudo crictl rm $(sudo crictl ps -q -a);

sudo mount |grep overlay |awk '{print $3}' |xargs sudo umount ;
sudo mount  |grep kubelet |awk '{print $3}' |xargs sudo umount ;

sudo rm -rf /var/lib/microshift;
sudo rm -rf /var/lib/kubelet; 
sudo crictl ps -a;


# podman run --privileged \
#          -d --rm --name ushift \
#         -v /var/run:/var/run \
#         -v /sys:/sys:ro \
#          -v /var/lib:/var/lib:rw,rshared \
#          -v /lib/modules:/lib/modules \
#          -v /etc:/etc \
#          -v /run/containers:/run/containers \
#          -v /var/log:/var/log \
#          -e KUBECONFIG=/var/lib/microshift/resources/kubeadmin/kubeconfig \
#          quay.io/microshift/microshift:4.7.0-0.microshift-2021-08-31-224727-linux-amd64
         
         


# --cidfile=%t/%n.ctr-id --sdnotify=conmon --cgroups=no-conmon--privileged -d --rm --name ushift -v /var/run:/var/run -v /sys:/sys:ro -v /var/lib:/var/lib:rw,rshared -v /lib/modules:/lib/modules -v /etc:/etc -v /run/containers:/run/containers -v /var/log:/var/log -e KUBECONFIG=/var/lib/microshift/resources/kubeadmin/kubeconfig quay.io/microshift/microshift:4.7.0-0.microshift-2021-08-31-224727-linux-amd64
