#!/bin/bash
# install-jenkins.sh — Installs Jenkins + Java + Docker on Ubuntu EC2
set -e

echo "==> Updating packages..."
sudo apt-get update -y

echo "==> Installing Java 11..."
sudo apt-get install -y openjdk-11-jdk

echo "==> Adding Jenkins repo..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "==> Installing Jenkins..."
sudo apt-get update -y
sudo apt-get install -y jenkins

echo "==> Starting Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "==> Installing Docker..."
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

echo ""
echo "============================================"
echo " ✅  Jenkins installed!"
echo " Access: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo " Initial password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "============================================"
