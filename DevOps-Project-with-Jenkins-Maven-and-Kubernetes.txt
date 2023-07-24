===============================Jenkins Installation==================================
https://www.jenkins.io/doc/book/installing/linux/
https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/
$ sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
$ sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
$ sudo yum upgrade
$ amazon-linux-extras install epel
$ sudo amazon-linux-extras install java-openjdk11 -y
$ yum install java-11-amazon-corretto -y
$ sudo yum install jenkins -y
$ sudo systemctl enable jenkins       //Enable the Jenkins service to start at boot
$ sudo systemctl start jenkins        //Start Jenkins as a service
$ java -version
$ javac -version
$ systemctl status jenkins
===============================Install and Configure Maven==================================
https://maven.apache.org/install.html
Copy the download link from https://maven.apache.org/download.cgi
$ sudo su  & cd ~
$ cd /opt
$ wget https://dlcdn.apache.org/maven/maven-3/3.9.3/binaries/apache-maven-3.9.3-bin.tar.gz
$ tar -xzvf apache-maven-3.9.3-bin.tar.gz
$ ls
$ mv apache-maven-3.9.3 maven
$ ll
$ cd maven
$ cd bin/
$ ./mvn -v  
$ cd ~
$ pwd
$ ll -a      //It will show the hidden files also
$ vim .bash_profile
$ find / -name java-11*
//enter below lines below the 2nd fi
M2_HOME=/opt/maven
M2=/opt/maven/bin
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.19.0.7-1.amzn2.0.1.x86_64
PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2
$ echo $PATH
$ source .bash_profile
$ echo $PATH
$ mvn -v
Java Path -- /usr/lib/jvm/java-11-openjdk-11.0.19.0.7-1.amzn2.0.1.x86_64
MAVEN_HOME:/opt/maven     //You need to add this at Jenkins Job under Maven Installations
===============================Ansible Server setup and Ansible Installation==================================
$ sudo nano /etc/hostname
$ useradd ansadmin
$ passwd ansadmin
$ visudo 
ansadmin ALL=(ALL)       NOPASSWD: ALL      //add this in sudo file.
$ cd /etc/ssh
$ nano sshd_config
$ service sshd reload
$ ssh-keygen
public key is at /home/ansadmin/.ssh/id_rsa.pub
$ sudo su , amazon-linux-extras install ansible2
$ ansible --version
===============================Integrate Ansible with Jenkins==================================
$ cd /opt
$ sudo mkdir docker
$ sudo chown ansadmin:ansadmin docker
Source files:webapp/target/*.war       Remove prefix:webapp/target        Remote directory://opt//docker
===============================Install and Configure Docker on Ansible Server==================================
$  sudo yum install docker
$ sudo usermod -aG docker ansadmin
$ id ansadmin
$ sudo service docker start
$ sudo systemctl start docker
$ nano Dockerfile
FROM tomcat:latest
RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
COPY ./*.war /usr/local/tomcat/webapps
===============================Create Ansible Playbook to Create Docker Image and Copy Image to DockerHub==================================
$ ifconfig 
$ sudo nano /etc/ansible/hosts
[ansible]
local-host-ip
$ ssh-copy-id local-host-ip
$ nano regapp.yml
---
- hosts: ansible

  tasks:
  - name: create docker image
    command: docker build -t regapp:latest .
    args:
     chdir: /opt/docker

  - name: create tag to push image onto dockerhub
    command: docker tag regapp:latest ashfaque9x/regapp:latest

  - name: push docker image
    command: docker push ashfaque9x/regapp:latest

$ ansible-playbook regapp.yml --check
$ ansible-playbook regapp.yml
Exec Command:ansible-playbook /opt/docker/regapp.yml
===============================Setup Bootstrap Server for eksctl==================================
# Install AWS Cli on the above EC2
Refer==https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
         OR
$ sudo yum remove -y aws-cli
$ pip3 install --user awscli
$ sudo ln -s $HOME/.local/bin/aws /usr/bin/aws
$ aws --version

# Installing kubectl
Refer===https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
$ curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
$ chmod +x ./kubectl 
$ mv kubectl /bin  OR $ mv kubectl /usr/local/bin
$ kubectl version --output=yaml

#Installing or eksctl
Refer==https://github.com/eksctl-io/eksctl/blob/main/README.md#installation
$ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
$ cd /tmp
$ sudo mv /tmp/eksctl /bin   OR  $ sudo mv /tmp/eksctl /usr/local/bin
$ eksctl version

# Setup Kubernetes using eksctl
Refer===https://github.com/aws-samples/eks-workshop/issues/734
eksctl create cluster --name virtualtechbox-cluster \
--region ap-south-1 \
--node-type t2.small \
$ kubectl get nodes

# Create deployment Manifest File
Refer===https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
$ nano regapp-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: virtualtechbox-regapp
  labels:
     app: regapp

spec:
  replicas: 2
  selector:
    matchLabels:
      app: regapp

  template:
    metadata:
      labels:
        app: regapp
    spec:
      containers:
      - name: regapp
        image: ashfaque9x/regapp
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1

# Create Service Manifest File 
Refer===https://kubernetes.io/docs/tutorials/services/connect-applications-service/
$ nano regapp-service.yml
apiVersion: v1
kind: Service
metadata:
  name: virtualtechbox-service
  labels:
    app: regapp 
spec:
  selector:
    app: regapp 

  ports:
    - port: 8080
      targetPort: 8080

  type: LoadBalancer

===============================Integrate Bootstrap Server with Ansible==================================
$ passwd root
$ nano /etc/ansible/hosts
[ansible]
localhost

[kubernetes]
BootStrap-Server-IP

$ ssh-copy-id root@BootStrap-Server-IP

# Create Ansible Playbook to Run Deployment and Service Manifest files
$ mv regapp.yml creat_image_regapp.yml 
$ nano kube_deploy.yml
---
- hosts: kubernetes
  user: root

  tasks:
    - name: deploy regapp on kubernetes
      command: kubectl apply -f regapp-deployment.yml

    - name: create service for regapp
      command: kubectl apply -f regapp-service.yml

    - name: update deployment with new pods if image updated in docker hub
      command: kubectl rollout restart deployment.apps/virtualtechbox-regapp

$ ansible-playbook kube_deploy.yml
Exec command:ansible-playbook /opt/Docker/kube_deploy.yml

===============================Cleanup==================================
$ kubectl delete deployment.apps/virtualtechbox-regapp
$ kubectl delete service/virtualtechbox-service
$ eksctl delete cluster virtualtechbox --region ap-south-1     OR    eksctl delete cluster --region=ap-south-1 --name=virtualtechbox-cluster


