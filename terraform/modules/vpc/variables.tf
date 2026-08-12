variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "az_count" {
  type = number
}

variable "vpc_cidr" {
  type = string
}

variable "ingress_cidrs" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
