###### Admin Network variables ######
variable id_network_admin {
	type = "string"
}

variable id_subnet_admin {
	type = "string"
}

# ###### Data Network variables ######
# variable id_network_data {
# 	type = "string"
# }
#
# variable id_subnet_data {
# 	type = "string"
# }

###### Variables security group ######
variable "data_sg" {
  type = "string"
}

variable "admin_sg" {
  type = "string"
}

variable "etcd_sg" {
  type = "string"
}

###### Variables Instances ######
variable "image_name" {
  type = "string"
}

variable "key_name" {
  type = "string"
}

### Bastion ###
variable "flavor_bastion" {
  type = "string"
}

### Master ###
variable "flavor_k8s_master" {
  type = "string"
}

variable "count_k8s_master" {
	default = 1
}

### Master ###
variable "flavor_k8s_node" {
  type = "string"
}

variable "count_k8s_node" {
	default = 1
}

### etcd ###
variable "flavor_k8s_etcd" {
  type = "string"
}

variable "count_k8s_etcd" {
	default = 1
}
