resource "aws_eks_cluster" "tf-demo" {
  name     = "tf-demo"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.private-1a.id, aws_subnet.private-1c.id, aws_subnet.public-1a.id, aws_subnet.public-1c.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}


resource "aws_eks_node_group" "managed-ng" {
  cluster_name    = aws_eks_cluster.tf-demo.name
  node_group_name = "managed-ng"
  node_role_arn   = aws_iam_role.eks_ng_role.arn
  subnet_ids      = [aws_subnet.private-1a.id, aws_subnet.private-1c.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  remote_access {
      ec2_ssh_key = "yfwang-Virginia"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}