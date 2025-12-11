# 1. Obtener la VPC existente por nombre
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["diego-vpc-vpc"]
  }
}

# 2. Obtener subnets de esa VPC
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# 3. Obtener el último AMI Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  owners = ["amazon"]
}

# 4. Crear EC2 usando esos data sources
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.small"
  subnet_id     = data.aws_subnets.selected.ids[0]
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
sudo yum install httpd -y
echo "Hola Mundo desde Terraform con Data Sources" > /var/www/html/index.html
sudo systemctl enable --now httpd
EOF

  tags = {
    Name = "diego-web-datasource"
  }
}