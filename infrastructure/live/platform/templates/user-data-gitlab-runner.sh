#!/bin/bash -xe

# usermod -s /bin/bash ssm-user
# curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh
# bash script.deb.sh
# apt install gitlab-runner docker.io ca-certificates curl gnupg -y

DOMAIN=$(aws ssm get-parameters --region us-east-1 --names /gitlab/domain_name --query Parameters[0].Value)
DOMAIN=$(echo $DOMAIN | sed -e 's/^"//' -e 's/"$//')

TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

if [[ -z "$TOKEN" ]]; then
  echo "Failed to get IMDSv2 token"
  exit 1
fi

INSTANCE_ID=$(curl -sH "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

if [[ -z "$INSTANCE_ID" ]]; then
  echo "Failed to get instance ID"
  exit 1
fi

SCRIPT_FILE="/usr/local/bin/setup-runner.sh"
cat > $SCRIPT_FILE <<EOF
#!/bin/bash
set -euo pipefail
GITLAB_RUNNER_AUTHENTICATION_TOKEN=\$(aws ssm get-parameters --region us-east-1 --names /gitlab/runner/runner_auth_token/$INSTANCE_ID --with-decryption --query Parameters[0].Value)
GITLAB_RUNNER_AUTHENTICATION_TOKEN=\$(echo \$GITLAB_RUNNER_AUTHENTICATION_TOKEN | sed -e 's/^"//' -e 's/"$//')

echo "Token: \$GITLAB_RUNNER_AUTHENTICATION_TOKEN"

if [ -z "\$GITLAB_RUNNER_AUTHENTICATION_TOKEN" ] || [ "\$GITLAB_RUNNER_AUTHENTICATION_TOKEN" = "null" ]; then
  echo "Error: Runner token is null"
  exit 1
fi

gitlab-runner register --non-interactive --url "https://gitlab.$DOMAIN/" --token "\$GITLAB_RUNNER_AUTHENTICATION_TOKEN" --executor "docker" --docker-image alpine:latest --description "docker-runner" --docker-privileged
EOF

chmod +x $SCRIPT_FILE

SERVICE_FILE="/etc/systemd/system/refresh-gitlab-runner-token.service"
cat > $SERVICE_FILE <<EOF
[Unit]
Description=GitLab Runner Bootstrap
After=network.target

[Service]
ExecStart=$SCRIPT_FILE
Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF


# Enable + start
systemctl enable refresh-gitlab-runner-token
systemctl start refresh-gitlab-runner-token