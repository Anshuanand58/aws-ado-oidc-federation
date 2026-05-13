variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = ""
}


variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM role for Azure DevOps OIDC authentication"
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

# variable "inline_policy_document" {
#   description = "Inline policy document JSON"
#   type        = string
#   default     = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = "sts:AssumeRole"
#         Resource = "*"
#       }
#     ]
#   })
# }

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
