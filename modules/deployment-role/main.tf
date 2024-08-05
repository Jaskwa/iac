
provider "aws" {
  region = var.region
}

locals {
  assume-role-policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow"
        Principal: {
            AWS: "arn:aws:iam::${var.tooling-account}:root"
        }
        Action: "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "deployment-role" {
  name = "${var.project}-${lower(var.artifact-name)}-deployer"
  assume_role_policy = local.assume-role-policy
}

data "aws_iam_policy_document" "policies" {
  for_each = var.attached-policies
  dynamic "statement" { 
    for_each = each
    content {
      effect = statement.value["effect"]
      actions = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}

resource "aws_iam_policy" "policies" {
  for_each = { for idx, policy in var.attached-policies: policy => idx }

  name = "${each.value.name}-policy"
  policy = aws_iam_policy_document.policies[each.key].json
}

resource "aws_iam_role_policy_attachment" "deployment-role-policy" {
  for_each = aws_iam_policy.policies

  role = aws_iam_role.deployment-role.name
  policy_arn = each.value.arn
}