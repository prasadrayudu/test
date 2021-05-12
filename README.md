Terraform apply steps: -
-----------------------------
terraform init
terraform apply -target=module.vpc
terraform apply

Terraform destroy steps: -
-------------------------------
terraform destroy -target=module.k3s_cluster
terraform destroy -target=module.vpc

