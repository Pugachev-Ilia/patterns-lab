locals {
  base_name = "${var.name}-${var.env}"
  tags = merge(var.tags, { Name = local.base_name })
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = "${local.base_name}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.tags, { Name = "${local.base_name}-igw" })
}

resource "aws_subnet" "public" {
  for_each                = {for i, az in var.azs : az => i}
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = var.public_subnet_cidrs[each.value]
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = "${local.base_name}-public-${each.key}", Tier = "public" })
}

resource "aws_subnet" "private" {
  for_each          = {for i, az in var.azs : az => i}
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = var.private_subnet_cidrs[each.value]
  tags = merge(local.tags, { Name = "${local.base_name}-private-${each.key}", Tier = "private" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.tags, { Name = "${local.base_name}-rt-public" })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  domain = "vpc"
  tags = merge(local.tags, { Name = "${local.base_name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = values(aws_subnet.public)[var.single_nat_gateway ? 0 : count.index].id
  tags = merge(local.tags, { Name = "${local.base_name}-nat-${count.index}" })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags = merge(local.tags, { Name = "${local.base_name}-rt-private-${each.key}" })
}

resource "aws_route" "private_0_0_0_0" {
  for_each               = var.enable_nat_gateway ? aws_route_table.private : {}
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : index(var.azs, each.key)].id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat([aws_route_table.public.id], [for _, rt in aws_route_table.private : rt.id])
  tags = merge(local.tags, { Name = "${local.base_name}-vpce-s3" })
}

data "aws_region" "current" {}
