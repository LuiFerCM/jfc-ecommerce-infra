output "cluster_name" { value = aws_ecs_cluster.main.name }
output "cluster_arn" { value = aws_ecs_cluster.main.arn }
output "service_name" { value = aws_ecs_service.api.name }
output "ecr_repository_arns" { value = [aws_ecr_repository.api.arn] }
output "ecr_repository_urls" { value = [aws_ecr_repository.api.repository_url] }
