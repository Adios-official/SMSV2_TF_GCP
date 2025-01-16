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

variable "slo_vpc_network" {
  description = "The VPC network where the subnetwork resides."
  type        = string
}

variable "sli_vpc_network" {
  description = "The VPC network where the subnetwork resides."
  type        = string
}

variable "slo_subnetwork_1" {
  description = "Subnetwork ID for the first instance."
  type        = string
}

variable "sli_subnetwork_1" {
  description = "Subnetwork ID for the first instance."
  type        = string
}


variable "az_name_1" {
  description = "Availability zone for the first instance."
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

variable "api_p12_file" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
}

variable "api_url" {
  type        = string
  description = "REQUIRED:  This is your Volterra API url"
}

variable "num_nics" {
  description = "Number of network interfaces (1 for single NIC, 2 for dual NIC)"
  type        = number
  default     = 1 # Default to single NIC
}
