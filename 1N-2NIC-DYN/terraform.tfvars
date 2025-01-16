# GCP Project ID - unique project ID from GCP that can be a combination of letters, numbers, and hyphens
# CHANGE THIS
project_id = "xxxxxxxxx"

# GCP Region
# CHANGE THIS
region = "europe-west3" # Change as necessary

# Base name for instance or nodes in your Customer Edge 
# CHANGE THIS
cluster_name = "xc-smsv2-google"

# GCP Instance Information
# Resources required per node: Minimum 4 vCPUs, 14 GB RAM, and 80 GB disk storage. 
instance_type = "n1-standard-4"                                              # Change as necessary
image         = "projects/xxxxxxx/global/images/xc-ce-image"                 # CHANGE THIS TO LOCATION OF THE NODE IMAGE 
disk_size     = 80                                                           # Disk size in GB. 80 GB is minimum.

# VPC Network
slo_vpc_network = "service-vpc-slo" # Add your VPC network name used for the SLO / Outside network interface

# VPC Network
sli_vpc_network = "service-vpc-sli" # Add your VPC network name used for the SLI / Inside network interface

# Subnetwork IDs / Subnet IDs
slo_subnetwork_1 = "slo-subnet-1" # Add your Subnet name used for the SLO / Outside network interface

# Subnetwork IDs / Subnet IDs
sli_subnetwork_1 = "sli-subnet-1" # Add your Subnet name used for the SLI / Inside network interface

# Availability Zone Details (for the node) 
az_name_1 = "europe-west3-a"


# Tags you would like to add to the nodes in the CE cluster. 
tags = ["f5ce", "adios"]

# Directly add your public key. This would be SSH key for Command line access to the nodes.
ssh_public_key = "ssh-rsa AAAAB3NzaC...."  

# These are arguments to supply your api creds for interacting with the XC Tenant
api_p12_file = "xxxxxx.console.ves.volterra.io.api-creds.p12"
api_url = "https://xxxxxx.console.ves.volterra.io/api"