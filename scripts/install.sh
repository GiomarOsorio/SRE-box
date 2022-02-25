#!/bin/bash

# remove comment if you want to enable debugging
#set -x

# create new ssh key
create_ssh(){
  [[ ! -f /home/ubuntu/.ssh/mykey ]] \
      && mkdir -p /home/ubuntu/.ssh \
      && ssh-keygen -f /home/ubuntu/.ssh/mykey -N '' \
      && chown -R ubuntu:ubuntu /home/ubuntu/.ssh
}

# update packages
packages_update(){
  apt-get -y update
}

# upgrade packages
packages_upgrade(){
  apt-get -y upgrade
}

# clear space
packages_clean(){
  apt-get clean
}

# install packages
packages_install(){
  apt-get -y install "$@"
}

# add repository
add_repository(){
  apt-add-repository --yes --update "${1}"
}

# docker install
docker_install(){
  packages_install ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  packages_update
  packages_install docker-ce docker-ce-cli containerd.io
  usermod -aG docker vagrant
}

# ansible install
ansible_install(){
  apt -y install software-properties-common
  add_repository "ppa:ansible/ansible"
  apt -y install ansible
}

# terraform install
terraform_install () {
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - 
  add_repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  packages_install terraform
}

# packer install
packer_install(){
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  add_repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  packages_update
  packages_install packer
}

# nodejs install
node_install(){
  curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
  packages_install nodejs
}

minikube_install(){
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    dpkg -i minikube_latest_amd64.deb
    minikube config set driver docker
}

# neovim install
nvim_install(){
  packages_install neovim
  npm -g install neovim bash-language-server
  pip install -U pynvim jedi jedi-language-server
  git clone https://github.com/GiomarOsorio/vim.git
  mv /home/vagrant/vim/.config /home/vagrant/.config
  chown -R vagrant:vagrant /home/vagrant/.config/
  rm -r /home/vagrant/vim
}

# azure cli install
azure_cli_install(){
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
}

# aws cli install
aws_cli_install(){
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
  rm awscliv2.zip
}

# gcloud cli install
gcloud_cli_install(){
  packages_install apt-transport-https ca-certificates gnupg
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
  packages_update
  packages_install google-cloud-sdk
}

# run configurations steps
provision_config(){
  create_ssh
  packages_update
  packages_install unzip python3-pip git
  docker_install
  ansible_install
  terraform_install
  packer_install
  node_install
  nvim_install
  minikube_install
  azure_cli_install
  aws_cli_install
  gcloud_cli_install
  packages_update
  packages_upgrade
  packages_clean
}

provision_config
