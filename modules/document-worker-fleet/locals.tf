locals {
  selected_ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.selected[0].id

  instance_names = [
    for index in range(var.instance_count) : format("%s-%02d", var.name_prefix, index + 1)
  ]

  worker_security_group_ids = concat(
    [aws_security_group.worker.id],
    var.additional_security_group_ids
  )

  artifact_object_arns = [
    for arn in var.artifact_bucket_arns : "${arn}/*"
  ]
}
