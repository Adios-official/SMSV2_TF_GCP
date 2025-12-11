################################################################################
# 1. F5 XC API CREDENTIALS
################################################################################

variable "api_p12_file" {
  description = "Path to the F5 XC API credential file (PKCS12)"
  type        = string
}

variable "api_url" {
  description = "F5 XC API URL (e.g., 'https://<tenant>.console.ves.volterra.io/api')"
  type        = string
}

################################################################################
# 2. F5 XC SITE CONFIGURATION
################################################################################

variable "cluster_name" {
  description = "Base name for the F5 XC site(s) and GCP resources. Must be a valid DNS-1035 label."
  type        = string

  validation {
    # This regex enforces DNS-1035 label requirements
    condition     = can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.cluster_name))
    error_message = "Invalid cluster_name: Must consist of lower case alphanumeric characters or '-', start with a letter, and end with an alphanumeric character."
  }
}

variable "deployment_model" {
  description = "The logical deployment model: 'cluster' (standard HA site) or 'vsite' (multiple independent sites grouped by a virtual_site)."
  type        = string
  default     = "cluster"

  validation {
    condition     = contains(["cluster", "vsite"], var.deployment_model)
    error_message = "The deployment_model must be either 'cluster' or 'vsite'."
  }
}

variable "num_nodes" {
  description = "Number of CE nodes to create. 'cluster' model supports 1 or 3. 'vsite' model supports 1 to 8."
  type        = number
  # Validation for count is handled by a 'check' block in main.tf
}

variable "num_nics" {
  description = "Number of network interfaces per node: 1 (SLO only) or 2 (SLO + SLI)."
  type        = number

  validation {
    condition     = contains([1, 2], var.num_nics)
    error_message = "The number of NICs must be either 1 or 2."
  }
}

variable "re_selection_mode" {
  description = "Controls how the Regional Edge (RE) is selected: 'auto' (geo_proximity) or 'manual' (requires primary_re_name)."
  type        = string
  default     = "auto"

  validation {
    condition     = contains(["auto", "manual"], var.re_selection_mode)
    error_message = "re_selection_mode must be 'auto' or 'manual'."
  }
}

variable "primary_re_name" {
  description = "The name of the specific Regional Edge to use when re_selection_mode is 'manual'."
  type        = string
  default     = "" # Must be empty if mode is 'auto'
}

variable "vrf_config" {
  description = "Configuration for Site Local VRFs (SLI/SLO), including static routes and DNS."
  type = object({
    slo_network_mode          = string 
    sli_network_mode          = string 
    static_route_prefixes_slo = list(string)
    static_route_next_hop_slo = string
    static_route_prefixes_sli = list(string)
    static_route_next_hop_sli = string
    nameserver_sli            = string
    nameserver_slo            = string
  })
  default = {
    slo_network_mode = "default"
    sli_network_mode = "default"
    static_route_prefixes_slo = []
    static_route_next_hop_slo = ""
    static_route_prefixes_sli = []
    static_route_next_hop_sli = ""
    nameserver_sli = ""
    nameserver_slo = ""
  }
}

################################################################################
# 3. GCP COMPUTE & IAM CONFIGURATION
################################################################################

variable "project_id" {
  description = "The GCP project ID where nodes and networks reside."
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources"
  type        = string
}

variable "az_name" {
  description = "List of GCP Zones. The number of zones must match 'var.num_nodes'."
  type        = list(string)
  # Validation for count is handled by a 'check' block in main.tf
}

variable "instance_type" {
  description = "GCP Machine Type for the CE nodes (e.g., 'n1-standard-4')"
  type        = string
}

variable "image" {
  description = "Full URL to the Custom GCP Image for the F5 XC CE nodes."
  type        = string
}

variable "disk_size" {
  description = "Root disk size in GB."
  type        = number
}

variable "tags" {
  description = "A list of custom GCP network tags to apply to all created resources."
  type        = list(string)
  default     = []
}

variable "ssh_public_key" {
  description = "The SSH public key content. Required for direct 'admin' access; leave blank to skip injection."
  type        = string
  default     = "" # Set a default empty string
}

variable "service_account_email" {
  description = "Email address of the Service Account to attach to the VM instance. Leave blank to skip service account attachment."
  type        = string
  default     = ""
}

variable "gcp_service_account_scopes" {
  description = "List of scopes granted to the Service Account (e.g., ['https://www.googleapis.com/auth/cloud-platform']). Only effective if a service_account_email is provided."
  type        = list(string)
  default     = []
}

################################################################################
# 4. GCP NETWORKING & FIREWALLS
################################################################################

variable "slo_vpc_network" {
  description = "The VPC network name for SLO (eth0) traffic."
  type        = string
}

variable "slo_subnetwork" {
  description = "List of Subnetwork names for the SLO (eth0) interface. Must match 'var.num_nodes'."
  type        = list(string)
}

variable "sli_vpc_network" {
  description = "The VPC network name for SLI (eth1) traffic (only if num_nics=2)."
  type        = string
}

variable "sli_subnetwork" {
  description = "List of Subnetwork names for the SLI (eth1) interface. Only used if 'num_nics = 2'."
  type        = list(string)
  default     = []
}

variable "network_tier" {
  description = "GCP Network Tier for public IP assignment ('STANDARD' or 'PREMIUM')."
  type        = string

  validation {
    condition     = contains(["STANDARD", "PREMIUM"], var.network_tier)
    error_message = "The network_tier must be either 'STANDARD' or 'PREMIUM'."
  }
}

variable "ip_configuration" {
  description = "IP configuration for the primary interface (SLO)."
  type = object({
    # The user input string defining the public IP assignment method.
    public_ip_assignment_type = string
    # List of existing Public IP addresses (used if public_ip_assignment_type = EXISTING_IP).
    existing_public_ips       = list(string)
  })
  default = {
    public_ip_assignment_type = "CREATE_IP"
    existing_public_ips       = []
  }

  validation {
    condition = contains(["CREATE_IP", "EXISTING_IP", "NONE"], var.ip_configuration.public_ip_assignment_type)
    error_message = "public_ip_assignment_type must be one of: 'CREATE_IP', 'EXISTING_IP', or 'NONE'."
  }
}

variable "create_firewall_rules" {
  description = "If true, Terraform will create the default F5 XC ingress/egress firewall rules in the VPC."
  type        = bool
  default     = true
}
