resource "aws_security_group" "worker" {
  name        = "${var.name_prefix}-workers"
  description = "Private document worker egress"
  vpc_id      = var.vpc_id

  egress {
    description = "Outbound to AWS APIs and private services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-workers"
  })
}

resource "aws_iam_role" "worker" {
  name               = "${var.name_prefix}-worker"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.name_prefix}-worker"
  role = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "worker_access" {
  count = length(var.secrets_arns) + length(var.artifact_bucket_arns) + length(var.kms_key_arns) == 0 ? 0 : 1

  name   = "${var.name_prefix}-worker-access"
  role   = aws_iam_role.worker.id
  policy = data.aws_iam_policy_document.worker_access.json
}

resource "aws_instance" "worker" {
  count = var.instance_count

  ami                    = local.selected_ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.worker.name
  key_name               = var.key_name
  subnet_id              = element(var.private_subnet_ids, count.index)
  vpc_security_group_ids = local.worker_security_group_ids
  ebs_optimized          = var.ebs_optimized

  user_data = var.user_data_template_path == null ? null : templatefile(var.user_data_template_path, merge(var.user_data_vars, {
    instance_name    = local.instance_names[count.index]
    instance_ordinal = tostring(count.index + 1)
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = var.root_block_device.volume_type
    volume_size           = var.root_block_device.volume_size
    encrypted             = var.root_block_device.encrypted
    kms_key_id            = try(var.root_block_device.kms_key_id, null)
    delete_on_termination = try(var.root_block_device.delete_on_termination, true)

    tags = merge(var.tags, var.worker_tags, {
      Name = "${local.instance_names[count.index]}-root"
    })
  }

  tags = merge(var.tags, var.worker_tags, {
    Name        = local.instance_names[count.index]
    ServiceRole = "document-worker"
  })

  lifecycle {
    ignore_changes = [
      ami,
      key_name,
      subnet_id,
      user_data,
      vpc_security_group_ids,
      root_block_device,
      tags["Name"]
    ]
  }
}

resource "aws_ebs_volume" "data" {
  count = var.data_volume == null ? 0 : var.instance_count

  availability_zone = aws_instance.worker[count.index].availability_zone
  type              = var.data_volume.volume_type
  size              = var.data_volume.volume_size
  encrypted         = var.data_volume.encrypted
  kms_key_id        = try(var.data_volume.kms_key_id, null)

  tags = merge(var.tags, var.worker_tags, {
    Name        = "${local.instance_names[count.index]}-data"
    ServiceRole = "document-worker"
  })
}

resource "aws_volume_attachment" "data" {
  count = var.data_volume == null ? 0 : var.instance_count

  device_name = var.data_volume.device_name
  volume_id   = aws_ebs_volume.data[count.index].id
  instance_id = aws_instance.worker[count.index].id
}
