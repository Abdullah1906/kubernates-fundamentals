### এই k8s-node-setup.sh ফাইলটা মূলত Kubernetes cluster-এর প্রতিটি EC2 node প্রস্তুত করার জন্য ব্যবহার করবে।

### তোমার ক্ষেত্রে যদি 1টা Control Plane + 2টা Worker Node থাকে, তাহলে তিনটা EC2-তেই এই একই script run করবে।

# এই script কী করবে?

## এটা automatically:

* Ubuntu update করবে
* Swap বন্ধ করবে
* Kubernetes-এর জন্য kernel modules enable করবে
* IP forwarding/network settings configure করবে
* containerd install করবে
* containerd-এ SystemdCgroup = true করবে
* Kubernetes repository add করবে
* kubelet, kubeadm, kubectl install করবে
* kubelet enable করবে

শেষে installation verify করবে

# কিন্তু এটা Kubernetes cluster তৈরি করবে না।

অর্থাৎ kubeadm init বা kubeadm join এই script-এর মধ্যে নেই।

Step-by-step

ধরো তোমার EC2-তে SSH করে ঢুকেছো:
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```
## Step 1 — Script file তৈরি

EC2-তে:

nano k8s-node-setup.sh

তারপর তোমার দেওয়া পুরো script paste করো।

Save:

Ctrl + O
Enter
Ctrl + X
## Step 2 — Execute permission দাও
```bash
chmod +x k8s-node-setup.sh
```
চেক:
```bash
ls -l k8s-node-setup.sh
```
এরকম দেখাবে:

-rwxr-xr-x ... k8s-node-setup.sh

## Step 3 — Script run করো
./k8s-node-setup.sh

অথবা:

bash k8s-node-setup.sh

আমি তোমার ক্ষেত্রে এটা ব্যবহার করতে বলব:
```bash
./k8s-node-setup.sh
```
## Step 4 — শেষ হলে verify

Script নিজেই verification করবে।

তবুও manually:
```bash
containerd --version
kubeadm version
kubectl version --client
kubelet --version
sudo systemctl status containerd
```

containerd-এর status:

active (running)

হওয়া উচিত।

## Step 5 — তিনটা EC2-তে একই কাজ

ধরো:
```text
Control Plane
    EC2-1

Worker 1
    EC2-2

Worker 2
    EC2-3

EC2-1 — Control Plane
./k8s-node-setup.sh
EC2-2 — Worker 1
./k8s-node-setup.sh
EC2-3 — Worker 2
./k8s-node-setup.sh
``` 
সব node-এ একই setup script।

## Step 6 — এরপর কী করবে?

সবগুলো node প্রস্তুত হওয়ার পর শুধু Control Plane-এ:

sudo kubeadm init ...

kubeadm init সফল হলে একটা command দেবে এরকম:

kubeadm join 10.x.x.x:6443 \
    --token xxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxx

এই kubeadm join command-টা Worker 1 এবং Worker 2-তে চালাবে।

তাহলে architecture হবে:

                 Kubernetes Cluster
                        │
              ┌─────────┴─────────┐
              │                   │
       Control Plane          Worker Nodes
          EC2-1                EC2-2
             │                 EC2-3
             │
        kubeadm init
             │
             └───────┬──────────────
                     │
              kubeadm join
## খুব গুরুত্বপূর্ণ
```text
তোমার বর্তমান script-এর কাজ হলো শুধু:

EC2 → Kubernetes-এর জন্য প্রস্তুত করা

এরপর:

Control Plane → kubeadm init

তারপর:

Workers → kubeadm join
```
