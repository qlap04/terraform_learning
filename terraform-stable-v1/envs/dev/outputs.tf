#command to init
output "init-backend-command" {
  value = "terraform init -reconfigure -backend-config=backend-dev.hcl"
}