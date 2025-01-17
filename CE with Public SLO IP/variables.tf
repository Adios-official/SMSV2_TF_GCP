##############################################################################################################################
# BLOCK 1 #  GCP BASIC VARIABLES
##############################################################################################################################

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region to deploy the instances."
  type        = string
}

##############################################################################################################################
# BLOCK 2 #  BASIC VARIABLES FOR CE 
##############################################################################################################################
variable "cluster_name" {
  description = "Base name for instances."
  type        = string
}


variable "instance_type" {
  description = "The instance type."
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

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key itself, directly input as a string."
}

variable "az_name" {
  description = "List of availability zones for the nodes."
  type        = list(string) # Change from string to list(string)
}

variable "num_nics" {
  description = "Number of network interfaces (1 for single NIC, 2 for dual NIC)"
  type        = number
  default     = 1 # Default to single NIC


  validation {
    condition     = var.num_nics == 1 || var.num_nics == 2
    error_message = "The number of nodes must be either 1 or 2. Any other value is not supported in this code."
  }
}

variable "num_nodes" {
  description = "Number of nodes (1 for single node, 3 for three nodes)."
  type        = number
  default     = 1

  validation {
    condition     = var.num_nodes == 1 || var.num_nodes == 3
    error_message = "The number of nodes must be either 1 or 3. The value '2' is not supported."
  }
}

variable "tags" {
  description = "List of network tags to apply to the instance"
  type        = list(string)
}


##############################################################################################################################
# BLOCK 3 #  NETWORKING AND NETWORK INTERFACES FOR NODES
# 3.1 SLO CONFIG 
##############################################################################################################################

variable "slo_vpc_network" {
  description = "The VPC network for SLO traffic."
  type        = string
}

variable "slo_subnetwork" {
  description = "List of subnetworks for the nodes."
  type        = list(string)
}

##############################################################################################################################
# BLOCK 3 #  NETWORKING AND NETWORK INTERFACES FOR NODES
# 3.2 SLI CONFIG 
##############################################################################################################################
variable "sli_vpc_network" {
  description = "The VPC network for SLI traffic."
  type        = string
}

variable "sli_subnetwork" {
  description = "List of subnetworks for the nodes."
  type        = list(string)
}

##############################################################################################################################
# BLOCK 4 # PUBLIC IP ASSIGNMENT VARIABLES
##############################################################################################################################

variable "ip_configuration" {
  description = "IP configuration, which includes public IP assignment type and existing public IPs."
  type = object({
    public_ip_assignment_type = string
    existing_public_ips = list(string)
  })
  default = {
    public_ip_assignment_type = "STATIC_NEW"
    existing_public_ips = []
  }

  validation {
    condition = (
      var.ip_configuration.public_ip_assignment_type != "STATIC_NEW" ||
      length(var.ip_configuration.existing_public_ips) == 0
    )
    error_message = "If public_ip_assignment_type is 'STATIC_NEW', existing_public_ips must be empty."
  }
}

variable "network_tier" {
  description = "Standard and Premium network tiers refer to the different levels of service that can be used for traffic routing through Google’s network"
  type        = string

  validation {
    condition     = var.network_tier == "STANDARD" || var.network_tier == "PREMIUM"
    error_message = "The network_tier must be either 'STANDARD' or 'PREMIUM'."
  }
}

##############################################################################################################################
# BLOCK 5 # AVAILABILITY ZONE DETAILS , TENANT DETAILS FROM DISTRIBUTED CLOUD
##############################################################################################################################
variable "api_p12_file" {
  type        = string
  description = "REQUIRED:  This is the path to the Volterra API Key.  See https://volterra.io/docs/how-to/user-mgmt/credentials"
}

variable "api_url" {
  type        = string
  description = "REQUIRED:  This is your Volterra API url"
}

