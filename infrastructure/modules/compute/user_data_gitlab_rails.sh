#!/bin/bash -xe

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

ROLE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
"http://169.254.169.254/latest/meta-data/iam/security-credentials/")

curl -H "X-aws-ec2-metadata-token: $TOKEN" \
"http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE"

DB_PASSWORD=$(aws ssm get-parameters --region us-east-1 --names /gitlab/postgresql/db_password --with-decryption --query Parameters[0].Value)
DB_PASSWORD=$(echo $DB_PASSWORD | sed -e 's/^"//' -e 's/"$//')

DB_USER=$(aws ssm get-parameters --region us-east-1 --names /gitlab/postgresql/db_user --query Parameters[0].Value)
DB_USER=$(echo $DB_USER | sed -e 's/^"//' -e 's/"$//')

DB_NAME=$(aws ssm get-parameters --region us-east-1 --names /gitlab/postgresql/db_name --query Parameters[0].Value)
DB_NAME=$(echo $DB_NAME | sed -e 's/^"//' -e 's/"$//')

DB_ENDPOINT=$(aws ssm get-parameters --region us-east-1 --names /gitlab/postgresql/db_endpoint --query Parameters[0].Value)
DB_ENDPOINT=$(echo $DB_ENDPOINT | sed -e 's/^"//' -e 's/"$//')

REDIS_ENDPOINT=$(aws ssm get-parameters --region us-east-1 --names /gitlab/redis/cache_endpoint --query Parameters[0].Value)
REDIS_ENDPOINT=$(echo $REDIS_ENDPOINT | sed -e 's/^"//' -e 's/"$//')

DOMAIN=$(aws ssm get-parameters --region us-east-1 --names /gitlab/domain_name --query Parameters[0].Value)
DOMAIN=$(echo $DOMAIN | sed -e 's/^"//' -e 's/"$//')

DB_PASSWORD=$(aws ssm get-parameters --region us-east-1 --names /gitlab/postgresql/db_password --with-decryption --query Parameters[0].Value)
DB_PASSWORD=$(echo $DB_PASSWORD | sed -e 's/^"//' -e 's/"$//')

RAILS_PASSWORD=$(aws ssm get-parameters --region us-east-1 --names /gitlab/rails/rails_password --with-decryption --query Parameters[0].Value)
RAILS_PASSWORD=$(echo $RAILS_PASSWORD | sed -e 's/^"//' -e 's/"$//')


FILE="/etc/gitlab/gitlab.rb"

cp "$FILE" "$FILE.bak"

cat > $FILE <<EOF
external_url 'https://gitlab.$DOMAIN'

letsencrypt['enable'] = false

postgresql['enable'] = false
gitlab_rails['db_adapter'] = "postgresql"
gitlab_rails['db_encoding'] = "unicode"
gitlab_rails['db_database'] = "$DB_NAME"
gitlab_rails['db_username'] = "$DB_USER"
gitlab_rails['db_password'] = "$DB_PASSWORD"
gitlab_rails['db_host'] = "$DB_ENDPOINT"

redis['enable'] = false
gitlab_rails['redis_host'] = "$REDIS_ENDPOINT"
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_ssl'] = true

nginx['listen_port'] = 80
nginx['listen_https'] = false

gitlab_sshd['enable'] = true
gitlab_sshd['listen_address'] = '[::]:2222'
gitlab_sshd['generate_host_keys'] = false

gitlab_rails['monitoring_whitelist'] = ['0.0.0.0/0']
gitlab_rails['initial_root_password'] = "$RAILS_PASSWORD"

gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['proxy_download'] = false
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'use_iam_profile' => true
}
gitlab_rails['object_store']['storage_options'] = {
  'server_side_encryption' => 'AES256',
}

gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts-fjal'
gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = 'gitlab-mr-diffs-fjal'
gitlab_rails['object_store']['objects']['lfs']['bucket'] = 'gitlab-lfs-fjal'
gitlab_rails['object_store']['objects']['uploads']['bucket'] = 'gitlab-uploads-fjal'
gitlab_rails['object_store']['objects']['packages']['bucket'] = 'gitlab-packages-fjal'
gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = 'gitlab-dependency-proxy-fjal'
gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = 'gitlab-terraform-state-fjal'
gitlab_rails['object_store']['objects']['ci_secure_files']['bucket'] = 'gitlab-ci-secure-files-fjal'
gitlab_rails['object_store']['objects']['pages']['bucket'] = 'gitlab-pages-fjal'

gitlab_rails['auto_migrate'] = true
EOF

export PGPASSWORD="$DB_PASSWORD"

/opt/gitlab/embedded/bin/psql -h "$DB_ENDPOINT" -U "$DB_USER" -d "$DB_NAME" <<EOF
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
EOF

gitlab-ctl reconfigure
gitlab-rake gitlab:check
gitlab-ctl status
