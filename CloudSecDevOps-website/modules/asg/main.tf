data "aws_availability_zones" "available_zones" {}
/* # Define AMI
data "aws_ami" "ubuntu" {
    most_recent =true
    owners = ["ClouSecDevOps"]
    filter {
        name ="name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }
}

resource "aws_key_pair" "my_aws_key" {
    key_name = "my_aws_key"
    public_key = file(var.PATH_TO_PUBLIC_KEY)
} */

# Define autoscaling launch configuration
resource "aws_launch_configuration" "launch-config" {
    name    = "${var.project_name}-launch-config"
    image_id = "ami-08fdec01f5df9998f"
    instance_type = "t2.micro"
    key_name = "var.key_name"
}

# Define frontend auto scaling group
resource "aws_autoscaling_group" "Cloudsecdevops-ASG" {
  name                      = "${var.project_name}-frontend-ASG"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  launch_configuration      = aws_launch_configuration.launch-config.name
  vpc_zone_identifier       = [var.Prod-webserver-Sbn_az1_id, var.Prod-webserver-Sbn_az2_id]
  
  tag {
    key                 = "Name"
    value               = "${var.project_name}-Webserver"
    propagate_at_launch = true
  }
}

# Define Backend auto scaling group
resource "aws_autoscaling_group" "Cloudsecdevops-Appserver-ASG" {
  name                      = "${var.project_name}-Backend-ASG"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  launch_configuration      = aws_launch_configuration.launch-config.name
  vpc_zone_identifier       = [var.Prod-Appserver-Sbn_az1_id, var.Prod-Appserver-Sbn_az2_id]
  
  tag {
    key                 = "Name"
    value               = "${var.project_name}-Appserver"
    propagate_at_launch = true
  }
}

# Define database auto scaling group
resource "aws_autoscaling_group" "Cloudsecdevops-DB-ASG" {
  name                      = "${var.project_name}-Database-ASG"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  launch_configuration      = aws_launch_configuration.launch-config.name
  vpc_zone_identifier       = [var.Prod-databbase-Sbn_az1_id, var.Prod-databbase-Sbn_az2_id]
  
  tag {
    key                 = "Name"
    value               = "${var.project_name}-DatabaseServer"
    propagate_at_launch = true
  }
}

# Define autoscaling policy scale-out policy
resource "aws_autoscaling_policy" "Scale-out-policy" {
  name                   = "Scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.Cloudsecdevops-ASG.name
  policy_type = "SimpleScaling"
}

# Define Cloudwatch monitoring for scale-out
resource "aws_cloudwatch_metric_alarm" "Scale-out-alarm" {
  alarm_name          = "Scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Cloudsecdevops-ASG.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.Scale-out-policy.arn]
}

# Define autodescaling policy - scale-in policy
resource "aws_autoscaling_policy" "Scale-In-policy" {
  name                   = "Scale-In-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.Cloudsecdevops-ASG.name
  policy_type = "SimpleScaling"
}
# Define Cloudwatch monitoring for scale-in
resource "aws_cloudwatch_metric_alarm" "Scale-In-alarm" {
  alarm_name          = "Scale-In-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Cloudsecdevops-ASG.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.Scale-In-policy.arn]
}
