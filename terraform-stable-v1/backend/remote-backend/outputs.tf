output "vpc_ids" {
  value = { for k, v in module.vpc : k => v.vpc_id }
}

output "private_subnets" {
  value = { for k, v in module.vpc : k => v.private_subnets }
}

output "public_subnets" {
  value = { for k, v in module.vpc : k => v.public_subnets }
}

# output "cmd" {
#     value = terraform plan -var-file="dev.tfvars"
# }