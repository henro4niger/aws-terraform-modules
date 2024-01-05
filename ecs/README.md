# Sample module invocation

### Create elastic file system (optional for application that requires volume mapping)
```
resource "aws_efs_file_system" "backend-app" {
  encrypted = true
  tags = {
    Name = "${var.env}-backend-app"
  }
}
module "efs_sg" {  #security group for elastic file system volume
  source       = "../security-group"
  rules        = var.backend_efs_sg_rules
  vpc_id       = var.vpc_id
}

resource "aws_efs_mount_target" "backend-app" {
  file_system_id  = aws_efs_file_system.backend-app.id
  subnet_id       = var.private_subnets[0]
  security_groups = [module.efs_sg.id]
  depends_on = [
    aws_efs_file_system.backend-app
  ]
}
```

## Create ecs Service
```
module "backend_sg" {  
  source       = "../security-group"
  rules        = var.backend_rules
  vpc_id       = var.vpc_id
  service_name = "backend-app"
  description  = "production backend service security group"
  env          = "production"
}

module "backend_svc" {
  service_name               = "backend-service"
  source                     = "./ecs_service"
  vpc_id                     = var.vpc_id
  container_name             = "backend-service" #optional if you want to override the default container name inferred from the first key of container_definitions map variables
  subnet_ids                 = var.private_subnets
  container_port             = 443
  tg_timeout                 = 5
  tg_interval                = 30
  tg_port                    = 443
  tg_unhealthy_threshold     = 6
  tg_healthy_threshold       = 2
  health_check_success_codes = "200-499"
  add_container_volume       = true
  add_container_volume2      = true
  volume_information         = ["app:/prod-backend/app", "scheduler:/prod-backend/scheduler", "queue:/prod-backend/queue"] #path on efs (similar to host path on server). The first part of each list entry before ":" corresponds to "volume_name" variable in the container_definitions below.
  efs_file_system_id         = aws_efs_file_system.backend-app.id
  listener_arn               = "load balancer listener arn"
  tg_name                    = "backend-service"
  lb_dns_name                = "load balancer dns name"
  route53_zone_id            = "Route53 zone id"
  tg_protocol                = "HTTPS"
  add_more_lb_rule           = true         #optional if you want to route create more than one listerner rule for the target group
  fqdn_2                     = "example.com" #must be provided if add_more_lb_rule is set to true
  fqdn                       = "example.net" #must be provided if expose_service is set to true (this is true by default)
  lb_zone_id                 = "load balancer zone ID"
  health_check_path          = "/health_check"
  desired_count              = 1
  ecs_cluster                = aws_ecs_cluster.prod_cluster.arn
  compute_info               = [8192, 16384]  #[cpu, memory]
  ephemeral_storage_size     = 180   #optional if you want to use more than the default 20GB ecs ephemaral storage
  security_groups            = [backend_sg.id]
  alb_arn_suffix             = "load balancer arn suffix"
  environmentfile            = "arn:aws:s3:::devops-env-bucket/env/backend-apps/prod-backend.env" #optionally you can provide path to env file in an S3 bucket
  container_definitions = {
    app = {
      image       = "091064108039.dkr.ecr.eu-west-2.amazonaws.com/backend:prod" #container image
      command     = []                                               #optionally provide command to overide container initialization command
      essential   = true                                             #set to true if you want the service to restart on failure of this container
      port        = 443                                              #container port
      environment = var.backend_app_env                      #enviroment variables for the container. In absence of any environment varible, set variable to "null"
      secret      = var.backend_secrets                      #similar to environment variable above
      volumename  = "app"                                            #container volume name, visible in the container task definition
      mount_path  = "/tmp"                                           #path within the container to map to host volume above
      volumename2 = "app"                                            #optional if you are mapping out more than one path in the container to host volume
      mount_path2 = "/var/www/laravel/storage/logs/jobs"
    }
    queue = { #optional sidecar second container. No port should be assigned to any sidecar containers as this is not allowed in AWS ECS Fargate.
      image       = "1234567890.dkr.ecr.eu-west-4.amazonaws.com/backend:prod"
      command     = []
      port        = 0
      essential   = true
      environment = var.backend_queue_env
      secret      = var.backend_secrets
      volumename  = "queue"
      mount_path  = "/tmp"
      volumename2 = "queue"
      mount_path2 = "/var/www/laravel/storage/logs/jobs"
    }
    scheduler = { #optional sidecar third container
      image       = "1234567890.dkr.ecr.eu-west-4.amazonaws.com/backend:prod"
      command     = []
      port        = 0
      essential   = true
      environment = var.backend_scheduler_env
      secret      = var.backend_secrets
      volumename  = "scheduler"
      mount_path  = "/tmp"
      volumename2 = "scheduler"
      mount_path2 = "/var/www/laravel/storage/logs/jobs"
    }
    artisan = { #optional sidecar fourth container
      image       = "1234567890.dkr.ecr.eu-west-4.amazonaws.com/backend:prod"
      command     = []
      port        = 0
      essential   = false
      environment = var.backend_artisan_env
      secret      = var.backend_secrets
      volumename  = "app"
      mount_path  = "/tmp"
      volumename2 = "app"
      mount_path2 = "/var/www/laravel/storage/logs/jobs"
    }
  }
```

# Variables
```
variable "backend_rules" {
  type = map(any)
  default = {
    "Allow connections on port 80 from local" = {
      from_port          = "80"
      to_port            = "80"
      protocol           = "tcp"
      allowed_cidr_block = "10.0.0.0/16"
    }
  }
}

variable "backend_app_env" {
  default = [
    {
      "name" : "DB"
      "value" : "postgresql"
    },
    {
      "name" : "DB_PORT"
      "value" : "5432"
    }
  ]
}

variable "backend_secrets" {
  default = [
    {
      "valueFrom" : "/path/to/parameter/db_host"
      "name" : "DB_HOST"
    },
    {
      "valueFrom" : "/path/to/parameter/db_user"
      "name" : "DB_USER"
    }
  ]
}
```

