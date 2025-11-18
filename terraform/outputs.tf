output "instance_public_ip" {
  value       = aws_instance.instance.public_ip
  description = "Public IP of the EC2 instance"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/auth.pem ubuntu@${aws_instance.instance.public_ip}"
  description = "SSH command to connect to instance"
}