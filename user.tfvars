#Need to define password for DB user for testing I have used test user
database_password = "1234"

# for allowed cidr blocks define ingress rule
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }
