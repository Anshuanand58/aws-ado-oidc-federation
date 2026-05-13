# Fetch the TLS certificate from the OIDC provider
data "tls_certificate" "azure_devops" {
  url = "https://vstoken.dev.azure.com"
}

# Create OIDC Provider for Azure DevOps
resource "aws_iam_openid_connect_provider" "azure_devops" {
  url            = data.tls_certificate.azure_devops.url
  client_id_list = ["api://AzureADTokenExchange"]
  thumbprint_list = [data.tls_certificate.azure_devops.certificates[0].sha1_fingerprint]

  tags = var.tags
}

# Create IAM Role with trust policy
resource "aws_iam_role" "azure_devops_oidc" {
  name        = var.role_name
  description = var.role_description

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::<account-id>:oidc-provider/vstoken.dev.azure.com/<organizationGUID>" # paste your role ARN
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
                "vstoken.dev.azure.com/<organizationGUID>:aud": "api://AzureADTokenExchange",
                "vstoken.dev.azure.com/<organizationGUID>:sub": "sc://<ORG_NAME>/<PROJECT_NAME>/<Service-connection-name>"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = toset(var.policy_arns)
  role       = aws_iam_role.azure_devops_oidc.name
  policy_arn = each.value
}

