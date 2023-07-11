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
===============================Install and Configure Docker Host==================================
$ sudo apt update && sudo apt-get update
$ sudo apt install docker.io
$ sudo usermod -aG docker ubuntu
$ sudo nano /etc/hostname
$ sudo init 6
$ chown -R ubuntu:ubuntu /opt
$ chown -R ubuntu:ubuntu /opt/Docker
$ cd /opt/Docker
$ nano Dockerfile      //Below is the content of Dockerfile
FROM tomcat:latest
RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
COPY ./*.war /usr/local/tomcat/webapps
$ docker build -t webapp:v1 .
$ docker stop registerapp
$ docker rm registerapp
$ docker run -d --name registerapp -p 8086:8080 webapp:v1
