provider "kubernetes" {
  host                   = aws_eks_cluster.tf-demo.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.tf-demo.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.tf-demo.name]
    command     = "aws"
  }
}
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
  depends_on = [
    aws_eks_node_group.managed-ng
  ]
}


resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "terraform-nginx"
    namespace = kubernetes_namespace.nginx.metadata.0.name
    labels = {
      app ="nginx"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app ="nginx"
      }
    }

    template {
      metadata {
        labels = {
          app ="nginx"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "nginx" {
  metadata {
    name = "terraform-nginx"
    namespace = kubernetes_namespace.nginx.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}