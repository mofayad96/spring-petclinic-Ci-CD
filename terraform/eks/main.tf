resource "aws_eks_cluster" "cluster" {
  name     = "springpetclinic-eks"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }
}
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/springpetclinic"
  retention_in_days = 7
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "springpetclinic-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.small"]
}

resource "aws_ecr_repository" "repo" {
  name = "springpetclinic"
}
