output "artifact_bucket_name" {
  description = "Artifact storage bucket name"
  value       = aws_s3_bucket.artifact_bucket.bucket
}

output "app_instance_id" {
  description = "Spring PetClinic EC2 instance ID"
  value       = aws_instance.app_server.id
}
