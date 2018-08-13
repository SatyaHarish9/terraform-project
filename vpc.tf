#--VPC for our application---

resource "aws_vpc" "my_vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags {
    Name = "myVPC"
  }
}

#--Internet gateway---

resource "aws_internet_gateway" "my_igw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "main"
  }
}

#---Subnets---

resource "aws_subnet" "public" {
  count = "${length(var.subnets_cidr)}"
  vpc_id = "${aws_vpc.my_vpc.id}"
  availability_zone = "${element(var.azs,count.index)}"
  cidr_block = "${element(var.subnets_cidr,count.index)}"
  map_public_ip_on_launch = true
  
  tags {
    Name = "Subnet-${count.index +1}"
  }
}

#---Route table and attach Internet gateway and associate it with subnet

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.my_vpc.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_igw.id}"
  }

  tags {
    Name = "PublicRT"
  }
}

# Attach route table with public subnets

resource "aws_route_table_association" "a" {
  count = "${length(var.subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

