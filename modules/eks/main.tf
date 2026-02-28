##############
# EKS Cluster
##############

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "malaa-cluster"
  cluster_version = "1.31"

  vpc_id                   = var.vpc_id
  subnet_ids               = [var.servers_subnet_id]
  control_plane_subnet_ids = [var.servers_subnet_id]

  enable_irsa = true

  eks_managed_node_groups = {
    malaa_nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      
      min_size     = 3
      max_size     = 10
      desired_size = 3

      subnet_ids = [var.servers_subnet_id]
    }
  }
}

##############
# PostgreSQL
##############

resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"

  namespace = "default"

  set {
    name  = "auth.database"
    value = "retool"
  }

  set {
    name  = "auth.username"
    value = "retool"
  }

  set {
    name  = "auth.password"
    value = "retoolpassword"
  }

  depends_on = [module.eks]
}

##############
# Retool
##############

resource "helm_release" "retool" {
  name       = "retool"
  repository = "https://charts.retool.com"
  chart      = "retool"

  namespace = "default"

  set {
    name  = "config.postgresql.host"
    value = "postgresql.default.svc.cluster.local"
  }

  set {
    name  = "config.postgresql.database"
    value = "retool"
  }

  set {
    name  = "config.postgresql.user"
    value = "retool"
  }

  set {
    name  = "config.postgresql.password"
    value = "retoolpassword"
  }

  set {
    name  = "postgresql.enabled"
    value = "false"
  }

  depends_on = [helm_release.postgresql]
}

##############
# Demo API
##############

resource "helm_release" "demo_api" {
  name  = "demo-api"
  chart = "${path.module}/helm-charts/demo-api"

  namespace = "default"


  depends_on = [module.eks]
}

##############
# Nginx Ingress
##############

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  depends_on = [module.eks]
}