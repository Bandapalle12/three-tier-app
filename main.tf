data "aws_iam_policy_document" "hello_world_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "hello_world_role" {
  name               = "hello-world-test-role"
  description        = "New Test role to verify Terraform S3 remote state"
  assume_role_policy = data.aws_iam_policy_document.hello_world_trust.json
}
