output "instance_ip" {
  value = aws_instance.flask_instance.public_ip  # Correct resource reference here
}
