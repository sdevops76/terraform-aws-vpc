resource "aws_vpc" "main" {
  cidr_block       = var.cidr_mv
  enable_dns_hostnames = true
  tags = {
    Name = "${var.proj_name_mv}-${var.env_mv}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id //This igw resource attached to this vpc
  tags = {
    Name = var.igw_mv
  }
}

resource "aws_subnet" "pubsnet-rn" {
  vpc_id     = aws_vpc.main.id
  count = length(var.pubsnets_cidrs_mv)
  cidr_block = var.pubsnets_cidrs_mv[count.index]

  tags = {
    Name = "${local.proj_env_name}-public-${local.az_names[count.index]}"
  }
}

resource "aws_subnet" "pvtsnet-rn" {
  vpc_id     = aws_vpc.main.id
  count = length(var.pvtsnets_cidrs_mv)
  cidr_block = var.pvtsnets_cidrs_mv[count.index]

  tags = {
    Name = "${local.proj_env_name}-private-${local.az_names[count.index]}"
  }
}

resource "aws_subnet" "dbsnet-rn" {
  vpc_id     = aws_vpc.main.id
  count = length(var.dbsnets_cidrs_mv)
  cidr_block = var.dbsnets_cidrs_mv[count.index]

  tags = {
    Name = "${local.proj_env_name}-db-${local.az_names[count.index]}"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.proj_env_name}-pub-RT"
  }
}

resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.proj_env_name}-pvt-RT"
  }
}

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.proj_env_name}-db-RT"
  }
}

resource "aws_route" "pub-routes" {
  route_table_id            = aws_route_table.pub_rt.id
  destination_cidr_block    = "0.0.0.0/0" #I think this is out going network
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pubsnet-rn[0].id
  tags = {
    Name = "${local.proj_env_name}-ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "pvt-routes" {
  route_table_id = aws_route_table.pvt_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}

resource "aws_route" "db-routes" {
  route_table_id = aws_route_table.db_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.pubsnets_cidrs_mv)
  subnet_id      = element(aws_subnet.pubsnet-rn[*].id, count.index)
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "private" {
  count = length(var.pvtsnets_cidrs_mv)
  subnet_id      = element(aws_subnet.pvtsnet-rn[*].id, count.index)
  route_table_id = aws_route_table.pvt_rt.id
}

resource "aws_route_table_association" "db" {
  count = length(var.pvtsnets_cidrs_mv)
  subnet_id      = element(aws_subnet.dbsnet-rn[*].id, count.index)
  route_table_id = aws_route_table.db_rt.id
}