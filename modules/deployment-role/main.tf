
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  aws-account-id = var.tooling-account != null ? var.tooling-account : data.aws_caller_identity.current.account_id
  assume-role-policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow"
        Principal: {
            AWS: "arn:aws:iam::${local.aws-account-id}:root"
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

# Do I need to use aws_iam_policy_document to be able to for_each this with a list of statements?
resource "aws_iam_policy" "policies" {
  for_each = var.attached-policies

  name = "${each.key}-policy"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "deployment-role-policy" {
  for_each = aws_iam_policy.policies

  role = aws_iam_role.deployment-role.name
  policy_arn = each.value.arn
}