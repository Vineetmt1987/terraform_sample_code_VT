provider "aws" {
  version    = "~> 2.0 "
  region     = "us-east-2"
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "terraform-vpc"
  }
}

#Internet gateway

resource "aws_internet_gateway" "gateway" {
  vpc_id = "aws_vpc.vpc.id"

  tags {
    Name = "terraform-internet-gateway"
  }
}

### Public subnet ###
resource "aws_subnet" "public_subnet" {
  vpc_id = "aws_vpc.vpc.id"
  count = "length(data.aws_availability_zones.available.names)"
  cidr_block  = "10.0.${count.index}.0/24"
  availability_zone  = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = true
  tags = {
	Name = "public-${element(data.aws_availability_zones.available.names, count.index)}"
}
}
### Private subnet ###
resource "aws_subnet" "private_subnet" {
  vpc_id = "aws_vpc.vpc.id"
  count = "{length(data.aws_availability_zones.available.names)"
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = false
  tags = {
	Name = "public-${element(data.aws_availability_zones.available.names, count.index)}"
}
}

### Routing table for private subnet ###
resource "aws_route_table" "private" {
  vpc_id = "aws_vpc.vpc.id"
  tags = {
	Name = "private-route-table"
  }
}
### Routing table for public subnet ###
resource "aws_route_table" "public" {
  vpc_id = "aws_vpc.vpc.id"
  tags = {
	Name = "public-route-table"
  }
}

### Default Security Group for vpc 
resource "aws_security_group" "default" {
  name        = "terraform_security_group"
  description = "Terraform security group"
  vpc_id      = "aws_vpc.vpc.id"

  # Allow outbound internet access.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terraform-security-group"
  }
}

#Create Application load balancer security group
resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = "aws_vpc.vpc.id"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terraform-alb-security-group"
  }
}


#Create new application load balancer

resource "aws_alb" "alb" {
  name            = "terraform-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.main.*.id}"]
  tags {
    Name = "terraform-alb"
  }
}

#Create target group for load balancer 

resource "aws_alb_target_group" "group" {
  name     = "terraform-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "aws_vpc.vpc.id"
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/login"
    port = 80
  }
}

#Create new application load balancer listener for HTTP client connection

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}

#Create new application load balancer listener for HTTPS client connection
resource "aws_alb_listener" "listener_https" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.certificate_arn}"
  default_action {
  target_group_arn = "${aws_alb_target_group.group.arn}"
  type             = "forward"
  }
}

# Create Route 53 :
resource "aws_route53_record" "terraform" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "terraform.${var.route53_hosted_zone_name}"
  type    = "A"
  alias {
    name                   = "${aws_alb.alb.dns_name}"
    zone_id                = "${aws_alb.alb.zone_id}"
    evaluate_target_health = true
  }
}

