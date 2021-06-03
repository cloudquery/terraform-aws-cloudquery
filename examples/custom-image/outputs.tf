output "image_name" {
  description = "Docker Image URI"
  value       = docker_registry_image.cloudquery.name
}

output "image_sha256_digest" {
  description = "Git repositories where webhook should be created"
  value       = docker_registry_image.cloudquery.sha256_digest
}
