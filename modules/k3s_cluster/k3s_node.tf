# A role has 1 or many policies
# An instance profile has 1 role
#
# (Role + Policy) is bound together by role_policy_attachment

resource "aws_iam_role" "k3s_node" {
  name               = "k3s_node_role-${local.cluster_id}"
  path               = "/"
  assume_role_policy = module.iam_policies.ec2_assume_role
}

resource "aws_iam_role_policy_attachment" "k3s_node" {
  role       = aws_iam_role.k3s_node.name
  policy_arn = module.iam_policies.k8s_node_full_arn
}

resource "aws_iam_role_policy_attachment" "k3s_node_session_manager" {
  role       = aws_iam_role.k3s_node.name
  policy_arn = module.iam_policies.session_manager_arn
}

resource "aws_iam_instance_profile" "k3s_node" {
  name = "k3s_node_instance_profile-${local.cluster_id}"
  role = aws_iam_role.k3s_node.name
}

# https://cloudinit.readthedocs.io/en/latest/topics/format.html
data "cloudinit_config" "k3s_node" {
  gzip          = true
  base64_encode = true

  # Debug with:
  # cat /tmp/k3s-agent-join-debug.log
  # Generated code can be found in /var/lib/cloud/instance/scripts (for debugging purpose)
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/user_data/node/k3s-agent-join.sh", {
      cluster_id     = local.cluster_id,
      cluster_token  = random_password.cluster_token.result,
      cluster_server = aws_instance.k3s_master.0.private_dns
    })
  }
}

