# AWS OIDC Azure DevOps Module

This module creates an OIDC (OpenID Connect) integration between AWS and Azure DevOps, enabling secure, federated authentication without requiring long-lived credentials.

## Features

- **OIDC Provider**: Creates an AWS IAM OIDC provider pointing to Azure DevOps (`https://vstoken.dev.azure.com`)
- **IAM Role**: Creates an IAM role with federated trust relationship to the OIDC provider
- **Policy Management**: Supports attaching managed policies and inline policies
- **Configurable**: Fully parameterized for flexible usage across different organizations and projects

## Resources Created

1. `aws_iam_openid_connect_provider` - Azure DevOps OIDC provider
2. `aws_iam_role` - IAM role with OIDC trust relationship
3. `aws_iam_role_policy_attachment` - Managed policy attachments
4. `aws_iam_role_policy` - Inline policy (optional)

## Trust Policy Structure

The module creates a trust policy that allows Azure DevOps service connections to assume the role. The policy includes:

- **Effect**: Allow
- **Principal**: The Azure DevOps OIDC provider
- **Action**: `sts:AssumeRoleWithWebIdentity`
- **Conditions**:
  - Audience: `api://AzureADTokenExchange` (default)
  - Subject: Service Connection reference in format `sc://{OrganizationName}/{ProjectName}/{ServiceConnectionName}`

## Usage Example

```hcl
module "azure_devops_oidc" {
  source = "./modules/aws_oidc_azure_devops"

  organization_guid       = "12345678-1234-1234-1234-123456789012"
  organization_name       = "YourOrganization"
  project_name            = "YourProject"
  service_connection_name = "AWS-Service-Connection"

  role_name   = "AWS-OIDC-Role"
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  tags = {
    Environment = "Production"
    Module      = "OIDC-Azure-DevOps"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization_guid | Azure DevOps Organization GUID | string | - | Yes |
| organization_name | Azure DevOps Organization Name | string | - | Yes |
| project_name | Azure DevOps Project Name | string | - | Yes |
| service_connection_name | Azure DevOps Service Connection Name | string | - | Yes |
| provider_url | Azure DevOps OIDC Provider URL | string | `https://vstoken.dev.azure.com` | No |
| provider_host | Azure DevOps OIDC Provider Host (used in conditions) | string | `vstoken.dev.azure.com` | No |
| audience | Azure DevOps OIDC Audience | string | `api://AzureADTokenExchange` | No |
| role_name | Name of the IAM role | string | `AWS-OIDC-Role` | No |
| role_path | Path of the IAM role | string | `/` | No |
| role_description | Description of the IAM role | string | `IAM role for Azure DevOps OIDC authentication` | No |
| policy_arns | List of policy ARNs to attach to the role | list(string) | `["arn:aws:iam::aws:policy/AdministratorAccess"]` | No |
| inline_policy_enabled | Enable inline policy attachment | bool | `false` | No |
| inline_policy_name | Name of the inline policy | string | `AzureDevOpsInlinePolicy` | No |
| inline_policy_document | Inline policy document JSON | string | - | No |
| tags | Tags to apply to resources | map(string) | `{}` | No |

## Outputs

| Name | Description |
|------|-------------|
| role_name | Name of the IAM role |
| role_arn | ARN of the IAM role |
| role_id | ID of the IAM role |
| oidc_provider_arn | ARN of the OIDC provider |
| oidc_provider_url | URL of the OIDC provider |
| assume_role_policy | Trust policy of the IAM role |

## Azure DevOps Configuration

After deploying this module, configure your Azure DevOps Service Connection with:

1. **Service Connection Type**: AWS
2. **Authentication Method**: Assume Role ARN
3. **Role ARN**: Use the `role_arn` output from this module
4. **External ID**: (Leave empty for OIDC-based authentication)
5. **Audience**: `api://AzureADTokenExchange`

## Security Notes

- This module uses federated authentication, eliminating the need for static AWS credentials in Azure DevOps
- The trust policy is scoped to specific organization, project, and service connection combinations
- Attach minimal necessary policies to the role following the principle of least privilege
- Consider using custom policies instead of `AdministratorAccess` for production environments

## References

- [AWS OIDC Provider Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Azure DevOps OIDC Integration](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints)
