#!/bin/bash -xe

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh
bash script.deb.sh
apt install gitlab-runner docker.io ca-certificates curl gnupg -y
