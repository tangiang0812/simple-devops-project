#!/bin/bash

export OCI_JSON=$(curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/projects" \
  --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
  --form "name=$PROJECT_NAME" \
  --form "visibility=private")

export OCI_PROJECT_ID=$(echo $OCI_JSON | jq -r '.id')
export OCI_HTTP_URL=$(echo $OCI_JSON | jq -r '.http_url_to_repo')
export OCI_SSH_URL=$(echo $OCI_JSON | jq -r '.ssh_url_to_repo')



export OCI_MANIFEST_JSON=$(curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/projects" \
  --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
  --form "name=$PROJECT_NAME-manifest" \
  --form "visibility=private")

export OCI_MANIFEST_PROJECT_ID=$(echo $OCI_MANIFEST_JSON | jq -r '.id')
export OCI_MANIFEST_HTTP_URL=$(echo $OCI_MANIFEST_JSON | jq -r '.http_url_to_repo')
export OCI_MANIFEST_SSH_URL=$(echo $OCI_MANIFEST_JSON | jq -r '.ssh_url_to_repo')

printf "Created GitLab app project with http url: %s\n" "$OCI_HTTP_URL"
printf "Created GitLab manifest project with http url: %s\n" "$OCI_MANIFEST_HTTP_URL"

export READONLY_TOKEN_JSON=$(curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/projects/$OCI_MANIFEST_PROJECT_ID/access_tokens" \
     --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
     --data "name=readonly-token" \
     --data "scopes[]=read_repository" \
     --data "expires_at=30")

export READONLY_TOKEN=$(echo $READONLY_TOKEN_JSON | jq -r '.token')

export READWRITE_TOKEN_JSON=$(curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/projects/$OCI_MANIFEST_PROJECT_ID/access_tokens" \
     --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
     --data "name=readwrite-token" \
     --data "scopes[]=read_repository" \
     --data "scopes[]=write_repository" \
     --data "expires_at=30")

export READWRITE_TOKEN=$(echo $READWRITE_TOKEN_JSON | jq -r '.token')

printf "Created read-only token with value: %s\n" "$READONLY_TOKEN"
printf "Created read-write token with value: %s\n" "$READWRITE_TOKEN"

curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/projects/$OCI_PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
  --form "key=GITLAB_MANIFEST_PAT" \
  --form "value=$READWRITE_TOKEN" \
  --form "protected=false" \
  --form "masked=true" \
  --form "hidden=true"

curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/projects/$OCI_PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
  --form "key=AWS_DEFAULT_REGION" \
  --form "value=$DEFAULT_REGION" \
  --form "protected=false" \
  --form "masked=false" \
  --form "hidden=false"

curl -s --request POST "https://gitlab.$DOMAIN_NAME/api/v4/projects/$OCI_PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_ROOT_TOKEN" \
  --form "key=AWS_ACCOUNT_ID" \
  --form "value=$AWS_ACCOUNT_ID" \
  --form "protected=false" \
  --form "masked=false" \
  --form "hidden=false"
