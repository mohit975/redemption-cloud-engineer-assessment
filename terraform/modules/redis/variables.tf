variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "redis_node_type" {
  type = string
}

variable "num_cache_clusters" {
  type = number
}

variable "tags" {
  type = map(string)
}
