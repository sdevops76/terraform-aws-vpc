output "azs_output_mv" {
  value = data.aws_availability_zones.azs_data.names
}

output vpc_id{
  value = aws_vpc.main.id
}