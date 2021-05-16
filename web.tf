# keypair 
resource "aws_key_pair" "deployer" {
  key_name   = "terraform_deployer"
  public_key = "${file(var.public_key_path)}"
}

# create EC2 Instance for web configurations:

resource "aws_launch_configuration" "launch_config" {
  name_prefix                 = "terraform-example-web-instance"
  image_id                    = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.deployer.id}"
  security_groups             = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  user_data                   = "${data.template_file.provision.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# Create an auto scaling group 

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = "${aws_launch_configuration.launch_config.id}"
  min_size             = "${var.autoscaling_group_min_size}"
  max_size             = "${var.autoscaling_group_max_size}"
  target_group_arns    = ["${aws_alb_target_group.group.arn}"]
  vpc_zone_identifier  = ["${aws_subnet.main.*.id}"]

  tag {
    key                 = "Name"
    value               = "terraform-example-autoscaling-group"
    propagate_at_launch = true
  }
}
