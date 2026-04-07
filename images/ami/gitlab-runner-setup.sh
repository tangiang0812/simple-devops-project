#!/bin/bash
set -xe

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh
sudo bash script.deb.sh
sudo apt install gitlab-runner docker.io ca-certificates curl gnupg -y