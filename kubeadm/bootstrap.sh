#!/bin/bash

echo ">>> SYSTEM UPDATE & UPGRADE"

sudo apt update
sudo apt -y upgrade

echo ">>> ADD KUBERNETES REPOS"

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sudo mv ~/kubernetes.list /etc/apt/sources.list.d

sudo apt update

echo ">>> INSTALL KUBE-* TOOLS"

sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl

echo ">>> KERNEL MODULES"

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

echo ">>> INSTALL DOCKER"

sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker

echo ">>> DISABLE SWAP"

sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sudo swapoff -a