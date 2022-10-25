data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    principals {
      identifiers = [
        data.aws_caller_identity.current.arn
      ]
      type = "AWS"
    }

    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "test_role_1" {
  name = "test-role-1-${var.deployment_identifier}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "test_role_2" {
  name = "test-role-2-${var.deployment_identifier}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "test_role_3" {
  name = "test-role-3-${var.deployment_identifier}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
