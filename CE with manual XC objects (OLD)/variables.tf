variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region to deploy the instances."
  type        = string
}

variable "cluster_name" {
  description = "Base name for instances."
  type        = string
}

variable "instance_type" {
  description = "The instance type."
  type        = string
}

variable "vpc_network" {
  description = "The VPC network where the subnetwork resides."
  type        = string
}

variable "subnetwork_1" {
  description = "Subnetwork ID for the first instance."
  type        = string
}

variable "subnetwork_2" {
  description = "Subnetwork ID for the second instance."
  type        = string
}

variable "subnetwork_3" {
  description = "Subnetwork ID for the third instance."
  type        = string
}

variable "az_name_1" {
  description = "Availability zone for the first instance."
  type        = string
}

variable "az_name_2" {
  description = "Availability zone for the second instance."
  type        = string
}

variable "az_name_3" {
  description = "Availability zone for the third instance."
  type        = string
}

variable "image" {
  description = "The image for the instance."
  type        = string
}

variable "disk_size" {
  description = "The size of the boot disk."
  type        = number
}

variable "token" {
  description = "Token to be written to user data."
  type        = string
}

# Uncomment PROXY only if you have an enterprise proxy in your Architecture. Please discuss with the F5 Engineer.
#variable "proxy" {
#  description = "Proxy to be written to user data."
#  type        = string
#}

variable "tags" {
  description = "List of network tags to apply to the instance"
  type        = list(string)
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key itself, directly input as a string."
}
