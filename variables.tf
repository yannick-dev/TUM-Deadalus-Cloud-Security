variable "region" {
  default = "eu-central-1"
}

variable "static_token" {
  description = "Static token for authentication, provided by a GitHub Secret"
  type        = string
  
}

variable "iam_role_name" {
  description = "A unique name for the student, passed in from the workflow."
  type        = string
}