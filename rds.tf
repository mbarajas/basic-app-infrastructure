resource "aws_db_parameter_group" "app-test-db-parameter-group" {
  name        = "app-test-db-parameter-group"
  family      = "aurora-postgresql11"
  description = "app-test-test-aurora-db-parameter-group"
  lifecycle {
    create_before_destroy = true
  }


resource "aws_rds_cluster_parameter_group" "app-test-cluster-parameter-group" {
  name        = "app-test-cluster-parameter-group"
  family      = "aurora-postgresql11"
  description = "app-test-aurora-cluster-parameter-group"
}


resource "aws_security_group_rule" "allow_access" {
  type              = "ingress"
  from_port         = module.db.this_rds_cluster_port
  to_port           = module.db.this_rds_cluster_port
  protocol          = "tcp"
  security_group_id = module.db.this_security_group_id
  self              = true
}

resource "aws_security_group_rule" "default_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.db.this_security_group_id
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 2.0"

  name = "app-test-db"

  engine         = "aurora-postgresql"
  engine_version = "11.7"

  vpc_id  = "${aws_vpc.app-test-vpc.id}"
  subnets = ["${aws_subnet.app-test-subnet-public-1.id}","${aws_subnet.app-test-subnet-public-2.id}"]

  replica_count       = 1
  instance_type       = "db.t3.medium"
  storage_encrypted   = true
  apply_immediately   = true
  skip_final_snapshot = false
  username = "app"
  password = "app123!!"

  db_parameter_group_name         = aws_db_parameter_group.app-test-db-parameter-group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.app-test-cluster-parameter-group.id

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Terraform = "true",
    Project = "App Test",
    Owner = "manuel.jose.barajas@gmail.com",
    Component = "database"
  }
}
