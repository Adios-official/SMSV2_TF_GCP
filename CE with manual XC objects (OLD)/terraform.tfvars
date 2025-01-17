# GCP Project ID - unique project ID from GCP that can be a combination of letters, numbers, and hyphens
# CHANGE THIS
project_id = "xxxxxxxxx"

# GCP Region
# CHANGE THIS
region = "europe-west3" # Change as necessary

# Base name for instances or nodes in your 3 node Customer Edge 
# CHANGE THIS
cluster_name = "xc-smsv2-google"

# GCP Instance Information
# Resources required per node: Minimum 4 vCPUs, 14 GB RAM, and 80 GB disk storage. 
instance_type = "n1-standard-4"                                              # Change as necessary
image         = "projects/xxxxxxx/global/images/xc-ce-image"                 # CHANGE THIS TO LOCATION OF THE NODE IMAGE 
disk_size     = 80                                                           # Disk size in GB. 80 GB is minimum.

# VPC Network
# CHANGE THIS
vpc_network = "service-vpc" # Add your VPC network name or ID here

# Subnetwork IDs / Subnet IDs
# CHANGE THIS TO YOUR SUBNET IDs
subnetwork_1 = "slo-subnet-1" # For node-1
subnetwork_2 = "slo-subnet-2" # For node-2
subnetwork_3 = "slo-subnet-3" # For node-3

# Availability Zones (one for each node) to ensure high availability 
# CHANGE THIS
az_name_1 = "europe-west3-a"
az_name_2 = "europe-west3-b"
az_name_3 = "europe-west3-c"

# User Data ( Uncomment PROXY only if you have an enterprise proxy in your Architecture. Please discuss with the F5 Engineer.)
# CHANGE THIS TO TOKEN YOU GOT FROM DISTRIBUTED CLOUD CONSOLE
token = "XXXXXXXXXXXXXXX........"
#proxy = "http://your-proxy-here:port"

# Tags you would like to add to the nodes in the CE cluster. 
# CHANGE THIS
tags = ["f5ce", "adios"]

# Directly add your public key. This would be SSH key for Command line access to the nodes.
# CHANGE THIS
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ....your-key-here"  
