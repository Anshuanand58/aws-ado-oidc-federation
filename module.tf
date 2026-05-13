# AWS OIDC Azure DevOps Module
module "aws_oidc_azure_devops" {
  source    = "./aws_oidc_azure_devops"
  role_name = "aws-oidc-azure-devops-role"
  policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
    # Add or replace with specific policies for your use case
  ]
  tags = {
    name        = "AWS OIDC Role"
    environment = "Production"
    provider    = "Azure-DevOps"
  }
}
