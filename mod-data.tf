data "aws_availability_zones" "azs_data" {
  state = "available"   #gets the azs which are available only.
}