#!/bin/bash -xe

# move this to packer AMI installation stage
# apt update && apt upgrade -y
# apt install -y unzip
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# ./aws/install

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

sed -i \
-e "s|^#\?\s*external_url .*|external_url 'https://$DOMAIN'|" \
-e "s|^#\?\s*letsencrypt\['enable'\].*|letsencrypt['enable'] = false|" \
-e "s|^#\?\s*postgresql\['enable'\].*|postgresql['enable'] = false|" \
-e "s|^#\?\s*gitlab_rails\['db_adapter'\].*|gitlab_rails['db_adapter'] = \"postgresql\"|" \
-e "s|^#\?\s*gitlab_rails\['db_encoding'\].*|gitlab_rails['db_encoding'] = \"unicode\"|" \
-e "s|^#\?\s*gitlab_rails\['db_database'\].*|gitlab_rails['db_database'] = \"$DB_NAME\"|" \
-e "s|^#\?\s*gitlab_rails\['db_username'\].*|gitlab_rails['db_username'] = \"$DB_USER\"|" \
-e "s|^#\?\s*gitlab_rails\['db_password'\].*|gitlab_rails['db_password'] = \"$DB_PASSWORD\"|" \
-e "s|^#\?\s*gitlab_rails\['db_host'\].*|gitlab_rails['db_host'] = \"$DB_ENDPOINT\"|" \
-e "s|^#\?\s*redis\['enable'\].*|redis['enable'] = false|" \
-e "s|^#\?\s*gitlab_rails\['redis_host'\].*|gitlab_rails['redis_host'] = \"$REDIS_ENDPOINT\"|" \
-e "s|^#\?\s*gitlab_rails\['redis_port'\].*|gitlab_rails['redis_port'] = 6379|" \
-e "s|^#\?\s*gitlab_rails\['redis_ssl'\].*|gitlab_rails['redis_ssl'] = true|" \
-e "s|^#\?\s*nginx\['listen_port'\].*|nginx['listen_port'] = 80|" \
-e "s|^#\?\s*nginx\['listen_https'\].*|nginx['listen_https'] = false|" \
-e "s|^#\?\s*gitlab_sshd\['enable'\].*|gitlab_sshd['enable'] = true|" \
-e "s|^#\?\s*gitlab_sshd\['listen_address'\].*|gitlab_sshd['listen_address'] = '[::]:2222'|" \
-e "s|^#\?\s*gitlab_rails\['monitoring_whitelist'\].*|gitlab_rails['monitoring_whitelist'] = ['0.0.0.0/0']|" \
-e "s|^#\?\s*gitlab_rails\['initial_root_password'\].*|gitlab_rails['initial_root_password'] = \"$RAILS_PASSWORD\"|" \
"$FILE"

export PGPASSWORD="$DB_PASSWORD"

/opt/gitlab/embedded/bin/psql -h "$DB_ENDPOINT" -U "$DB_USER" -d "$DB_NAME" <<EOF
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
EOF

gitlab-ctl reconfigure
gitlab-rake gitlab:check
gitlab-ctl status
