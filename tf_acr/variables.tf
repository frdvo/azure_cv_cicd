# Variables
variable "location" {
  type        = string
  default     = "Australia East"
  description = "Enter the nearest Azure Region"
}

variable "name_prefix" {
  type        = string
  description = "Enter a prefix to allow a unique name"
}
