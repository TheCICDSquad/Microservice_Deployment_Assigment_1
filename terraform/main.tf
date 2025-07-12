module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size               = var.min_size
      max_size               = var.max_size
      desired_size           = var.desired_size
      instance_types         = [var.instance_type]
      capacity_type          = "ON_DEMAND"
      vpc_security_group_ids = [aws_security_group.eks_nodes.id]

      labels = {
        Environment = var.environment
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }

      update_config = {
        max_unavailable_percentage = 50
      }

      lifecycle {
        ignore_changes = [scaling_config[0].desired_size]
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size               = var.min_size
      max_size               = var.max_size
      desired_size           = var.desired_size
      instance_types         = [var.instance_type]
      capacity_type          = "ON_DEMAND"
      vpc_security_group_ids = [aws_security_group.eks_nodes.id]

      labels = {
        Environment = var.environment
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
          "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }

      update_config = {
        max_unavailable_percentage = 50
         }

      lifecycle {
        ignore_changes = [scaling_config[0].desired_size]
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
   Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name        = "${var.cluster_name}-nodes"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "helm_release" "currency_converter" {
  name       = "currency-converter"
  repository = null  # Using local chart
  chart      = "./helm/currency-converter"
  namespace  = "default"
  wait       = true
  timeout    = 600

  set {
    name  = "image.repository"
    value = "${var.docker_registry}/${var.docker_image}"
  }

  set {
    name  = "image.tag"
    value = var.docker_image_tag
  }

  set {
    name  = "apiKey"
    value = var.exchange_rate_api_key
  }

  set_sensitive {
    name  = "apiKey"
    value = var.exchange_rate_api_key
  }

  depends_on = [
    module.eks.eks_managed_node_groups
  ]
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to image tag as CI/CD will update it
      set[1].value
    ]
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "currency_converter" {
  metadata {
    name = "currency-converter"
    namespace = "default"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = helm_release.currency_converter.name
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        select_policy               = "Min"
        policy {
          period_seconds = 60
          type           = "Pods"
          value          = 1
        }
      }
      scale_up {
        stabilization_window_seconds = 60
        select_policy               = "Max"
        policy {
          period_seconds = 60
          type           = "Pods"
          value          = 2
        }
      }
    }
  }

  depends_on = [helm_release.currency_converter]
}