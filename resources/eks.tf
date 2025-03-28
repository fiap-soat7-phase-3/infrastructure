resource "aws_eks_cluster" "t75-eks_cluster" {
  name = "t75-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.t75-vpc_subnet1.id, aws_subnet.t75-vpc_subnet2.id]
    security_group_ids = [aws_security_group.t75-sg.id]
    # cluster_security_group_id = aws_security_group.t75-sg.id
    endpoint_public_access = true
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group" "t75-eks-node_group" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  node_group_name = "t75-eks-node-group"
  node_role_arn = aws_iam_role.eks_node_group.arn
  subnet_ids = [aws_subnet.t75-vpc_subnet1.id, aws_subnet.t75-vpc_subnet2.id]
  instance_types = ["t3.medium"]

  depends_on = [aws_eks_cluster.t75-eks_cluster]

  scaling_config {
    desired_size = 1
    max_size = 2
    min_size = 1
  }

  update_config {
    max_unavailable = 1
  }
}

# 1. Create the IAM role
# EKS Cluster Role (for the control plane)
resource "aws_iam_role" "eks_cluster_role" {
  name = "t75-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Create the access entry
resource "aws_eks_access_entry" "t75_eks_access_entry" {
  cluster_name  = aws_eks_cluster.t75-eks_cluster.name
  principal_arn = aws_iam_role.eks_cluster_role.arn
}

resource "aws_eks_access_policy_association" "t75-eks_access_policy" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.eks_cluster_role.arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.t75_eks_access_entry]
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}