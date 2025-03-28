resource "aws_security_group" "t75-sg" {
  name = "t75-sg"
  vpc_id = aws_vpc.t75-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # REQUIRED FOR EKS
  ingress {
    description = "Cluster API server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ideally restrict to your VPC CIDR
  }

  ingress {
    description = "Node-to-node communication"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Node-to-node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
}