resource "aws_iam_role" "sftp_transfer_server" {
  name = "${var.prefix}-sftp-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-sftp-iam-role"
    },
  )
}

resource "aws_iam_role_policy" "sftp_transfer_server" {
  name = "${var.prefix}-sftp-transfer-server-iam-policy"
  role = aws_iam_role.sftp_transfer_server.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_transfer_server" "sftp" {
  endpoint_type                = "PUBLIC"
  identity_provider_type       = "SERVICE_MANAGED"
  domain                       = "S3"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-sftp-server"
    },
  )
  logging_role                 = aws_iam_role.sftp_transfer_server.arn
  lifecycle {
      ignore_changes           = [tags]
  }
}


resource "null_resource" "associate_custom_hostname" {
  provisioner "local-exec" {
    command = <<EOF
~/.local/bin/aws transfer tag-resource \
  --arn '${aws_transfer_server.sftp.arn}' \
  --tags \
    'Key=aws:transfer:customHostname,Value=${var.custom_hostname}' \
  --region '${var.region}'
EOF
  }
  depends_on = [aws_transfer_server.sftp]
}