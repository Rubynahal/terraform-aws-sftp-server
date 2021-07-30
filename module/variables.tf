variable "prefix" {
    description    = "prefix to be used in naming of resources"
}

variable "region" {
    description = "valid region name"
    type        = string
}

variable "custom_hostname" {
    description  = "custom hostname for fsx"
    type         = string
}

variable "tags" {
    type = map(string)
    default = {}
}
