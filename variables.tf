variable "rds_instance_identifier" {}
variable "database_name" {}
variable "database_password" {}
variable "database_user" {}

variable "allowed_cidr_blocks" {
  type = "list"
}
variable "s3_bucket_name" {}

variable "amis" {
  type = "map"
}
variable "instance_type" {}
variable "autoscaling_group_min_size" {}
variable "autoscaling_group_max_size" {}
