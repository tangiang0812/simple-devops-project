#!/bin/bash -xe

# usermod -s /bin/bash ssm-user
# curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" -o script.deb.sh
# bash script.deb.sh
# apt install gitlab-runner docker.io ca-certificates curl gnupg -y

DOMAIN=$(aws ssm get-parameters --region us-east-1 --names /gitlab/domain_name --query Parameters[0].Value --output text)

if [[ -z "$DOMAIN" ]]; then
  echo "Failed to get DOMAIN"
  exit 1
fi

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

SCRIPT_FILE="/usr/local/bin/register-gitlab-runner.sh"
cat > $SCRIPT_FILE <<EOF
#!/bin/bash
set -euo pipefail



GITLAB_ACCESS_TOKEN=\$(aws ssm get-parameters --region us-east-1 --names /gitlab/runner/gitlab_access_token --with-decryption --query Parameters[0].Value --output text)

echo "GITLAB_ACCESS_TOKEN: \$GITLAB_ACCESS_TOKEN"

if [ -z "\$GITLAB_ACCESS_TOKEN" ] || [ "\$GITLAB_ACCESS_TOKEN" = "null" ] || [ "\$GITLAB_ACCESS_TOKEN" = "None" ]; then
  echo "Error: GITLAB_ACCESS_TOKEN is null or empty"
  exit 1
fi

RUNNER_AUTH_TOKEN=\$(curl -s --request POST "https://gitlab.$DOMAIN/api/v4/user/runners" \
  --header "PRIVATE-TOKEN: \$GITLAB_ACCESS_TOKEN" \
  --form "runner_type=instance_type" \
  --form "description=docker-runner-$INSTANCE_ID" \
  --form "run_untagged=true" \
  --form "locked=false" \
  --form "active=true" | jq -r '.token')

echo "RUNNER_AUTH_TOKEN: \$RUNNER_AUTH_TOKEN"

if [ -z "\$RUNNER_AUTH_TOKEN" ] || [ "\$RUNNER_AUTH_TOKEN" = "null" ]; then
  echo "Error: RUNNER_AUTH_TOKEN is null or empty"
  exit 1
fi

gitlab-runner register --non-interactive --url "https://gitlab.$DOMAIN/" --token "\$RUNNER_AUTH_TOKEN" --executor "docker" --docker-image alpine:latest --description "docker-runner-$INSTANCE_ID" --docker-privileged
EOF

chmod +x $SCRIPT_FILE

SERVICE_FILE="/etc/systemd/system/register-gitlab-runner.service"
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
systemctl enable register-gitlab-runner
systemctl start register-gitlab-runner