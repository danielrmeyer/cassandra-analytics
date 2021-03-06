module "cassandra_security_group" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_cassandra"
  security_group_name = "${var.security_group_name}-cassandra"
  vpc_id = "${var.vpc_id}"
  source_cidr_block = "${var.source_cidr_block}"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_subnet" "main" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "172.31.32.0/20"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2a"
  tags {
    Name = "${var.user_name}_Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.user_name}"
  }
}


resource "aws_route_table" "r" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_network_acl" "main" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.main.id}"]
  egress{
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  ingress {
    protocol = "all"
    rule_no = 1
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  tags {
    Name = "${var.user_name}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_security_group" "allow_internet_access" {
  name = "allow_internet_access"
  description = "Allow outbound internet communication."
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "{var.user_name}"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_ssh_access" {
  name = "allow_all_ssh_access"
  description = "ALlow ssh access from any ip"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "var.user_name"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_spark_ui_access" {
  name = "allow_spark_ui_access"
  description = "Allow access to spark ui from any ip"
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "var.user_name"
  }
  
  ingress {
    from_port = 4040
    to_port = 4040
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_subnet_traffic" {
  name = "allow_all_subnet_traffic"
  description =  "Allow all traffic from inside subnet"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "var.user_name"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.source_cidr_block}"]
  }
}
