# Crerate the S3 Access role with an infinite policy allwoing the AWS CLI to assume roles :

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"
  path = "/"

  assume_role_policy = << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
               "Service": "s3.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "profile" {
  name = "terraform_instance_profile"
  role = "${aws_iam_role.s3_access_role.name}"
}




#  AWS iam policy to the S3 Access role permissions


resource "aws_iam_role_policy" "s3_code_bucket_access_policy" {
  name = "s3_code_bucket_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}/*"]
    }
  ]
}
EOF
}


#Enable logging :

resource "aws_s3_bucket" "log_bucket" {
  bucket = "log-bucket"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "b" {
  bucket = "test-bucket"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "/var/log/"
  }
}

