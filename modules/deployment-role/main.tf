
provider "aws" {
  region = var.region
}

locals {
  terraform-state-access-policies = ["dynamo-state-access", "s3-state-access"]
  assume-role-policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow"
        Principal: {
            AWS: "arn:aws:iam::${var.tooling_account}:root"
        }
        Action: "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "deployment-role" {
  name = "${var.project}-${lower(var.artifact_name)}-deployer"
  assume_role_policy = local.assume-role-policy
}

output "deployment-role-arn" {
  value = aws_iam_role.deployment-role.arn
}

data "aws_iam_policy_document" "policies" {
  for_each = var.attached_policies
  dynamic "statement" {
    for_each = each.value
    content {
      effect = statement.value["effect"]
      actions = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

resource "aws_iam_policy" "policies" {
  for_each = { for idx, policy in data.aws_iam_policy_document.policies: idx => policy }
  name = "${each.key}-policy" # not going to pretend I understand why the index of the policy document in the name of the policy in vars...
  policy = each.value.json
}

resource "aws_iam_role_policy_attachment" "deployment-role-policy" {
  for_each = aws_iam_policy.policies

  role = aws_iam_role.deployment-role.name
  policy_arn = each.value.arn
}

data "aws_iam_policy" "terraform-state-access" {
  for_each = { for name in local.terraform-state-access-policies: name => name }

  name = each.key
}

resource "aws_iam_role_policy_attachment" "terraform-state-access" {
  for_each = data.aws_iam_policy.terraform-state-access

  role = aws_iam_role.deployment-role.name
  policy_arn = each.value.arn
}