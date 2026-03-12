resource "aws_ssm_parameter" "gitlab_db_user" {
  name      = "/gitlab/postgresql/db_user"
  type      = "String"
  data_type = "text"
  value     = var.gitlab_db_user
  tier      = "Standard"
  overwrite = true

}
resource "aws_ssm_parameter" "gitlab_db_name" {
  name      = "/gitlab/postgresql/db_name"
  type      = "String"
  data_type = "text"
  value     = var.gitlab_db_name
  tier      = "Standard"
  overwrite = true

}
resource "aws_ssm_parameter" "gitlab_db_endpoint" {
  name      = "/gitlab/postgresql/db_endpoint"
  type      = "String"
  data_type = "text"
  value     = var.gitlab_db_endpoint
  tier      = "Standard"
  overwrite = true

}
resource "aws_ssm_parameter" "gitlab_db_password" {
  name      = "/gitlab/postgresql/db_password"
  type      = "SecureString"
  data_type = "text"
  value     = var.gitlab_db_password
  tier      = "Standard"
  overwrite = true
}
# resource "aws_ssm_parameter" "efs_dns" {
#   name      = "/A4L/Wordpress/EFSFSID"
#   type      = "String"
#   data_type = "text"
#   value     = var.efs_dns_name
#   tier      = "Standard"
#   overwrite = true
# }
resource "aws_ssm_parameter" "domain_name" {
  name      = "/gitlab/domain_name"
  type      = "String"
  data_type = "text"
  value     = var.domain_name
  tier      = "Standard"
  overwrite = true

}
resource "aws_ssm_parameter" "gitlab_redis_endpoint" {
  name      = "/gitlab/redis/cache_endpoint"
  type      = "String"
  data_type = "text"
  value     = var.gitlab_redis_endpoint
  tier      = "Standard"
  overwrite = true

}

resource "aws_ssm_parameter" "cw_agent_config" {
  name      = "/cwagent/config"
  type      = "String"
  overwrite = true

  value = <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/var/log/secure",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/var/log/httpd/access_log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/var/log/httpd/error_log",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
      "ImageId": "$${aws:ImageId}",
      "InstanceId": "$${aws:InstanceId}",
      "InstanceType": "$${aws:InstanceType}"
    },
    "metrics_collected": {
      "collectd": {
        "metrics_aggregation_interval": 60
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"],
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "used_percent",
          "inodes_free"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "diskio": {
        "measurement": [
          "io_time",
          "write_bytes",
          "read_bytes",
          "writes",
          "reads"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "statsd": {
        "metrics_aggregation_interval": 60,
        "metrics_collection_interval": 10,
        "service_address": ":8125"
      },
      "swap": {
        "measurement": ["swap_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF
}
