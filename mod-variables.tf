variable "cidr_mv" {
  type = string
  default = "10.0.0.0/16"
}

variable "proj_name_mv" {
  type = string
}

variable "env_mv" {
  type = string
}

variable "igw_mv" {
  type = string
  default = "roboshop-igw-mv"
}

variable "pubsnets_cidrs_mv" {
  type = list
  validation {
    condition = length(var.pubsnets_cidrs_mv) == 2
    error_message = "Please give 2 public valid subnet CIDR"
  }
}

variable "pvtsnets_cidrs_mv" {
  type = list
  validation {
    condition = length(var.pvtsnets_cidrs_mv) == 2
    error_message = "Please give 2 private valid subnet CIDR"
  }
}

variable "dbsnets_cidrs_mv" {
  type = list
  validation {
    condition = length(var.dbsnets_cidrs_mv) == 2
    error_message = "Please give 2 db valid subnet CIDR"
  }
}



