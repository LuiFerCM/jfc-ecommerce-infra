output "cluster_endpoint" { value = aws_rds_cluster.main.endpoint }
output "reader_endpoint" { value = aws_rds_cluster.main.reader_endpoint }
output "cluster_identifier" { value = aws_rds_cluster.main.cluster_identifier }
