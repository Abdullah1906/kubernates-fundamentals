#!/usr/bin/env bash

set -e

echo "=============================================="
echo " Kubernetes Node Setup"
echo " Kubernetes Version: v1.29"
echo " Runtime: containerd"
echo "=============================================="

# ------------------------------------------------
# 1. Update system
# ------------------------------------------------
echo "[1/10] Updating system..."

sudo apt update -y

sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    git \
    netcat-openbsd


# ------------------------------------------------
# 2. Disable Swap
# ------------------------------------------------
echo "[2/10] Disabling swap..."

sudo swapoff -a

sudo sed -i '/\bswap\b/s/^/#/' /etc/fstab

echo "Current swap status:"
free -h | grep Swap || true


# ------------------------------------------------
# 3. Load Kernel Modules
# ------------------------------------------------
echo "[3/10] Configuring kernel modules..."

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter


# ------------------------------------------------
# 4. Configure Sysctl
# ------------------------------------------------
echo "[4/10] Configuring network settings..."

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system


# ------------------------------------------------
# 5. Add Docker Repository
# ------------------------------------------------
echo "[5/10] Adding Docker repository..."

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


# ------------------------------------------------
# 6. Install containerd
# ------------------------------------------------
echo "[6/10] Installing containerd..."

sudo apt-get update -y

sudo apt-get install -y containerd.io

sudo mkdir -p /etc/containerd

containerd config default \
    | sudo tee /etc/containerd/config.toml > /dev/null

sudo sed -i \
    's/SystemdCgroup = false/SystemdCgroup = true/' \
    /etc/containerd/config.toml

sudo systemctl restart containerd

sudo systemctl enable containerd

echo "containerd status:"
sudo systemctl is-active containerd


# ------------------------------------------------
# 7. Add Kubernetes Repository
# ------------------------------------------------
echo "[7/10] Adding Kubernetes repository..."

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL \
    https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
    | sudo gpg --dearmor \
    -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list


# ------------------------------------------------
# 8. Install Kubernetes Components
# ------------------------------------------------
echo "[8/10] Installing Kubernetes..."

sudo apt-get update

sudo apt-get install -y \
    kubelet \
    kubeadm \
    kubectl

sudo apt-mark hold \
    kubelet \
    kubeadm \
    kubectl


# ------------------------------------------------
# 9. Enable kubelet
# ------------------------------------------------
echo "[9/10] Enabling kubelet..."

sudo systemctl enable kubelet


# ------------------------------------------------
# 10. Verify Installation
# ------------------------------------------------
echo "[10/10] Verifying installation..."

echo ""
echo "----------------------------------------------"
echo "containerd:"
containerd --version

echo ""
echo "kubeadm:"
kubeadm version

echo ""
echo "kubectl:"
kubectl version --client

echo ""
echo "kubelet:"
kubelet --version

echo ""
echo "Swap:"
free -h | grep Swap || true

echo ""
echo "containerd service:"
sudo systemctl is-active containerd

echo ""
echo "=============================================="
echo " Kubernetes node setup completed!"
echo "=============================================="
echo ""
echo "Next step:"
echo "  Control Plane: sudo kubeadm init ..."
echo "  Worker Node:   sudo kubeadm join ..."
echo ""
