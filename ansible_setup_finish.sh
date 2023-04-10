#!/bin/bash
### Warning Message ####
cat <<EOT
This Tool is able to run only if AWSCLI is installed and configured!
EOT


### Collecting Required Params ###
read -p "Enter AWS profile [default]: " aws_profile
aws_profile=${aws_profile:-default}
read -p "Enter name of Infra Keypair [rcss_util]: " infra_keypair_name
infra_keypair_name=${infra_keypair_name:-rcss_util}
read -p "Enter name of GitHub User [pavel-rcss]: " github_name
github_name=${github_name:-pavel-rcss}
read -p "Enter name of GitHub Mail [pavel@rcss.co.il]: " github_mail
github_mail=${github_mail:-pavel@rcss.co.il}
read -p "Enter name of GitHub SSH key [gh_jenkins]: " github_key_name
github_key_name=${github_key_name:-gh_jenkins}

### Finish Ansible Config ###
sudo ansible-config init --disabled > ~/ansible.cfg
sudo sed -i 's/^\(;enable_plugins=.*\)/\1, aws_ec2/' ~/ansible.cfg
sudo mv ~/ansible.cfg /etc/ansible/

### Set required SSH Keys ###
infra_keypair_value=$(aws secretsmanager get-secret-value --secret-id "${infra_keypair_name}-private" --query 'SecretString' --output text --profile "${aws_profile}")
sudo echo "${infra_keypair_value}" > ~/.ssh/id_rsa
sudo chmod 400 ~/.ssh/id_rsa

github_key_value=$(aws secretsmanager get-secret-value --secret-id "${github_key_name}-private" --query 'SecretString' --output text --profile "${aws_profile}")
sudo echo "${github_key_value}" > ~/.ssh/github_key
sudo chmod 400 ~/.ssh/github_key

### Clone Ansible Playbooks Repo ###
git config --global user.email "${github_mail}"
git config --global user.name "${github_name}"
GIT_SSH_COMMAND='ssh -i ~/.ssh/github_key' git clone git@github.com:pavel-rcss/ops_school_project_ansible.git
