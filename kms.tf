data "aws_iam_policy_document" "execute_command_key" {
  count = var.enable_execute_command_logging ? 1 : 0

  statement {
    sid       = "EnableIAMUserPermissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogsToUseKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = [local.execute_command_log_group_arn]
    }
  }
}

resource "aws_kms_key" "execute_command" {
  count = var.enable_execute_command_logging ? 1 : 0

  description = "${var.component}-${var.deployment_identifier}-ecs-cluster-${var.cluster_name}-exec-kms-key"
  policy      = data.aws_iam_policy_document.execute_command_key[0].json
}
