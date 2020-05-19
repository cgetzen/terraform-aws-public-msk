variable "cluster_name" {
  type = string
  description = "The existing MSK cluster to expose publically"
}

variable "tags" {
  type    = map(string)
  default = {}
  description = "Additional EIP tags"
}

variable "propogate_tags" {
  type    = bool
  default = true
  description = "Propogate MSKs tags to the EIPs"
}

variable "check_errors" {
  type    = bool
  default = true
  description = "Checks if MSK is configured properly"
}

variable "create_host_file" {
  type    = bool
  default = true
  description = "Creates /etc/hosts file necessary to connect to MSK"
}
