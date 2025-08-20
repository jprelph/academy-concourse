# Primary EKS Cluster

# Global Role Setup
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "eks_sm_access" {
  provider           = aws.primary
  name               = "eks-pod-identity"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "sm" {
  provider   = aws.primary
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.eks_sm_access.name
}

module "eks" {
  source   = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  providers = {
    aws = aws.primary
  }
  
  name    = var.cluster_name
  kubernetes_version = "1.33"
  endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m7i.large"]
      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = setunion(
    module.vpc.public_subnets,
    module.vpc.private_subnets
  )
  node_iam_role_name = "${var.cluster_name}-node-role"
  node_iam_role_use_name_prefix = false
  node_iam_role_tags = {
    "cluster" = var.cluster_name
  }
  node_security_group_tags = {
    "cluster" = var.cluster_name
  }
}