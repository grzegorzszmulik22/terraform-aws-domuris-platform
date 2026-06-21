locals {
  environment = [
    for key, value in var.environment : {
      name  = key
      value = value
    }
  ]

  secrets = [
    for key, arn in var.secret_arns : {
      name      = key
      valueFrom = arn
    }
  ]
}
