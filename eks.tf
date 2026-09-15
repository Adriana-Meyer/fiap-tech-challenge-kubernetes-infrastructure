# AWS Academy Learner Lab only allows pre-created IAM roles (no custom
# roles/policies) — but the actual names aren't the clean "LabEksClusterRole"/
# "LabEksNodeRole" the generic Lab docs describe. Each lab instance gets a
# unique prefix/suffix (e.g. "c221562a...-LabEksClusterRole-x7tTWFEXrXCi"),
# and the cluster and node group use two DIFFERENT roles, not one shared
# role — so an exact-name lookup fails. Match by substring instead.
data "aws_iam_roles" "eks_cluster_role" {
  name_regex = ".*LabEksClusterRole.*"
}

data "aws_iam_roles" "eks_node_role" {
  name_regex = ".*LabEksNodeRole.*"
}

locals {
  eks_cluster_role_arn = tolist(data.aws_iam_roles.eks_cluster_role.arns)[0]
  eks_node_role_arn    = tolist(data.aws_iam_roles.eks_node_role.arns)[0]
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = local.eks_cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = local.eks_node_role_arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  tags = {
    Name = "${var.project_name}-node-group"
  }

  depends_on = [aws_eks_cluster.main]
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}
