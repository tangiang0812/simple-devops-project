#!/bin/bash
set -xe

sudo systemctl enable --now ssh
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

sudo rm -f /usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg

curl https://packages.gitlab.com/gpg.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg

# sudo apt-get update
# sudo apt-get install -y curl


curl --location "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh" | sudo bash

sudo apt-get install gitlab-ce=17.11.7-ce.0 -y


# curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh
# sudo bash script.deb.sh
# sudo apt-get install gitlab-runner docker.io ca-certificates curl gnupg -y