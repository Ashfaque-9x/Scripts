-------------------------------------- Both Master & Worker Node ---------------------------------------
sudo apt update -y
sudo apt install docker.io -y

sudo systemctl start docker
sudo systemctl enable docker

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install kubeadm=1.20.0-00 kubectl=1.20.0-00 kubelet=1.20.0-00 -y
--------------------------------------------- Master Node -------------------------------------------------- 
sudo su
====== Disable swap if it is enabled ========
sudo swapon --show
sudo swapoff -a
vi /etc/fstab        
============================================
kubeadm init
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubeadm token create --print-join-command
--------------------------------------------- Worker Node --------------------------------------------------
sudo su
====== Disable swap if it is enabled ======
sudo swapon --show
sudo swapoff -a
vi /etc/fstab   
============================================
kubeadm reset pre-flight checks
complete-output-of-join-command --v=5
----------------------------------------------------------------------------------------------------------------------------------------
If getting below message as output of command "kubectl get nodes",
The connection to the server localhost:8080 was refused - did you specify the right host or port? Then perform the following on Master
root@ubuntuvm22:/home/vadmin# export KUBECONFIG=/etc/kubernetes/admin.conf
root@ubuntuvm22:/home/vadmin# cp /etc/kubernetes/admin.conf $HOME/
root@ubuntuvm22:/home/vadmin# chown $(id -u):$(id -g) $HOME/admin.conf
root@ubuntuvm22:/home/vadmin# export KUBECONFIG=$HOME/admin.conf
root@ubuntuvm22:/home/vadmin# kubectl get nodes
----------------------------------------------------------------------------------------------------------------------------------------
