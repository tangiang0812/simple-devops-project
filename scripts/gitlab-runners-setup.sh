#!/bin/bash
export RUNNER_AUTH_TOKEN=$(curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/user/runners" \
  --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
  --form "runner_type=instance_type" \
  --form "description=docker-runner" \
  --form "run_untagged=true" \
  --form "locked=false" \
  --form "active=true" | jq -r '.token')

echo
echo "---- Gitlab runner setup command ----"
echo "sudo gitlab-runner register --non-interactive --url \"https://gitlab.$DOMAIN_NAME/\" --token \"$RUNNER_AUTH_TOKEN\" --executor \"docker\" --docker-image alpine:latest --description \"docker-runner\" --docker-privileged"
echo "---- Gitlab runner setup command ----"
echo
