# Variables
variable "docker_login_server" {
  type        = string
  default     = "docker.io"
  description = "Container Server"
}

variable "container_name" {
  type        = string
  default     = "pedrojunqueira/flask-cv_web"
  description = "Container Name"
}

variable "container_tag" {
  type        = string
  default     = "latest"
  description = "Container Tag"
}

variable "location" {
  type        = string
  default     = "Australia East"
  description = "Enter the nearest Azure Region"
}

variable "name_prefix" {
  type        = string
  description = "Enter a prefix to allow a unique name"
}

variable "end_point" {
  type        = string
  description = "Enter your Azure Cognitive Services End Point"
}

variable "subscription_key" {
  type        = string
  description = "Enter your Azure Cognitive Services Subscription Key"
  sensitive = true
}

variable "rg_name" {
  type        = string
  description = "Azure Resource Group Name"
}

variable "docker_access_token" {
  type        = string
  description = "Enter Docker Access Token"
  sensitive = true
}
