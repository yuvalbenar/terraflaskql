output "instance_ip" {
  value = aws_instance.flask_app.public_ip
  description = "The public IP address of the EC2 instance"
}
