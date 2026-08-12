variable "name" {
  type = string
}

variable "cloudwatch_log_retention_days" {
  type = number
}

variable "tags" {
  type = map(string)
}
