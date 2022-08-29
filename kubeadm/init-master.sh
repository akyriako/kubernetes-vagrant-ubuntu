#!/bin/bash

echo ">>> INIT MASTER NODE"

sudo systemctl enable kubelet

kubeadm init \
  --apiserver-advertise-address=$MASTER_NODE_IP \
  --pod-network-cidr=$K8S_POD_NETWORK_CIDR \
  --ignore-preflight-errors=NumCPU

echo ">>> CONFIGURE KUBECTL"

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown 900:900 /home/vagrant/.kube/config

echo ">>> FIX KUBELET NODE IP"

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$MASTER_NODE_IP\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo ">>> DEPLOY POD NETWORK (FLANNEL) "

# kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# curl -o canal.yml https://github.com/projectcalico/canal/blob/master/k8s-install/1.7/canal.yaml
# sed -i.bak 's|"/opt/bin/flanneld",|"/opt/bin/flanneld", "--iface=enp0s8",|' canal.yml
# kubectl create -f canal.yml

kubectl create -f /vagrant/cni/flannel/kube-flannel.yml

sudo systemctl daemon-reload
sudo systemctl restart kubelet

echo ">>> GET WORKER JOIN COMMAND "

rm -f /vagrant/kubeadm/init-worker.sh
kubeadm token create --print-join-command >> /vagrant/kubeadm/init-worker.sh
