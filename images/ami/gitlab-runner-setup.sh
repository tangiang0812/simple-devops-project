#!/bin/bash
set -xe
sudo rm -f /usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg

curl https://packages.gitlab.com/gpg.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/gitlab_gitlab-ce-archive-keyring.gpg

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh
sudo bash script.deb.sh
sudo apt-get install gitlab-runner docker.io ca-certificates curl gnupg -y