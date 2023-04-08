#!/bin/bash
### Warning Message ####
cat <<EOT
This Tool is able to run only if AWSCLI is installed and configured!
EOT


### Collecting Required Params ###
read -p "Enter AWS profile [default]: " aws_profile
aws_profile=${aws_profile:-default}
read -p "Enter name of Infra Keypair: " infra_keypair_name
read -p "Enter name of GitHub User: " github_name
read -p "Enter name of GitHub Mail: " github_mail
read -p "Enter name of GitHub SSH key: " github_key_name

### Disable host key checking for SSH connections ###
ssh_options="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

### Finish Ansible Config ###
sudo ansible-config init --disabled > ansible.cfg
sudo sed -i 's/^\(;enable_plugins=.*\)/\1, aws_ec2/' ansible.cfg
sudo mv ansible.cfg /etc/ansible/

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
