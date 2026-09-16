# EKS doesn't ship metrics-server by default — Repo 4's HPA needs it to
# read CPU/memory via metrics.k8s.io. EKS-managed add-on instead of Helm
# since AWS offers it natively and it needs no IAM role (only talks to
# kubelets, never an AWS API).
#
# addon_version left unset on purpose, same reasoning as
# kubernetes_version in eks.tf: pinning it just creates future upkeep.
resource "aws_eks_addon" "metrics_server" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.main]
}
