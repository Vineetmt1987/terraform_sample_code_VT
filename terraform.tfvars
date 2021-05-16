rds_instance_identifier = "terraform-mysql"
database_name = "terraform_test_db"
database_user = "terraform"

s3_bucket_name = "springboot-s3-example"

#Define ami :

resource "aws_instance" "terraform" {
ami = "ami-03d64741867e7bb94"
instance_type = "t2.micro"
autoscaling_group_min_size = 3
autoscaling_group_max_size = 5
}
