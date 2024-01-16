locals {
  proj_env_name = "${var.proj_name_mv}-${var.env_mv}"
  az_names = slice(data.aws_availability_zones.azs_data.names,0,2)
}
