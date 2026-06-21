output "topic_arn" {
  description = "SNS topic ARN for alarms."
  value       = aws_sns_topic.alarms.arn
}

output "alarm_names" {
  description = "Created CloudWatch alarm names."
  value = concat(
    values(aws_cloudwatch_metric_alarm.ecs_cpu_high)[*].alarm_name,
    values(aws_cloudwatch_metric_alarm.ecs_memory_high)[*].alarm_name,
    aws_cloudwatch_metric_alarm.alb_target_5xx[*].alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu_high[*].alarm_name,
    aws_cloudwatch_metric_alarm.rds_free_storage_low[*].alarm_name,
    aws_cloudwatch_metric_alarm.redis_cpu_high[*].alarm_name
  )
}
