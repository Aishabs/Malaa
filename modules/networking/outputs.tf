output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "servers_subnet_id" {
  description = "Servers Private Subnet ID"
  value       = aws_subnet.servers.id
}

output "database_subnet_id" {
  description = "Database Private Subnet ID"
  value       = aws_subnet.database.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "dmz_subnet_id" {
  description = "DMZ Subnet ID"
  value       = aws_subnet.dmz.id
}