# kubernates-fundamentals
## kubeadm (Self-Hosted)
```bash
AWS ap-south-1 — devops-vpc (10.0.0.0/16)
┌─────────────────────────────────────────────────────┐
│  Public Subnet (ap-south-1a)                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  Master Node (t3.medium, Ubuntu 22.04)       │   │
│  │  • kube-apiserver   :6443                    │   │
│  │  • etcd             :2379                    │   │
│  │  • kube-scheduler                            │   │
│  │  • kube-controller-manager                   │   │
│  │  • Calico CNI (podCIDR: 192.168.0.0/16)      │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  Private Subnets (1b / 1c)                          │
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │  Worker Node 1       │  │  Worker Node 2       │ │
│  │  t3.medium           │  │  t3.medium           │ │
│  │  kubelet + containerd│  │  kubelet + containerd│ │
│  └──────────────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────┘
```
working steps:
```text
master-init-guide.md
     |
worker-join-guide.md
     |
 then others file
```


### Here is step file for master node and worker node for kubeadm. 
### master-init-guide.md for master node and worker-join-guide.md for worker node.
### class-12
