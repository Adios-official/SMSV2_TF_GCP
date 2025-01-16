##############################################################################################################################
# BLOCK 1 #  GCP BASIC VARIABLES
##############################################################################################################################

# GCP Project ID - unique project ID from GCP that can be a combination of letters, numbers, and hyphens
# CHANGE THIS
project_id = "f5-gcs-6556-gs-cot04"

# GCP Region
# CHANGE THIS
region = "europe-west3" # Change as necessary

# Base name for instance or nodes in your Customer Edge 
# CHANGE THIS
cluster_name = "adios-smsv2-gcp-2nic-nonat-dyn"

##############################################################################################################################
# BLOCK 2 #  BASIC VARIABLES FOR CE NODE
# GCP Instance Information
# Resources required per node: Minimum 4 vCPUs, 14 GB RAM, and 80 GB disk storage
##############################################################################################################################
instance_type = "n1-standard-4"                                              # Change as necessary
image         = "projects/f5-gcs-6556-gs-cot04/global/images/adios-ce-image" # Use a suitable image
disk_size     = 80                                                           # Disk size in GB. 80 GB is minimum.
tags = ["f5ce", "adios"]                                                     # Tags you would like to add to the nodes in the CE cluster. 
az_name_1 = "europe-west3-a"                                                 # Availability Zone of the node
# Directly add your public key. This would be SSH key for Command line access to the nodes.
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbddme6xpnBgi4WU48iZQ34yQ5/ItN5oPcAjYN3rpXfhbZjBClBgTeLqD6AqB52LsBCs8VLdLXw7HC4LuQRAYg/+cIzSYWbYewETcAG7Te8sVEKL3Qc9kSkIkLN64+5yF8Gh4DYEd9ZHxfrBbFO2pO1yTil+EtO56kudaCWEurKI2KoIW8APNnTPL/Qb33YA/x8Xt6bHPSZEOyUX0WpyH1sKAK0yiRC8jTXodTPhVFQLLPAdRfHznc5T7IUcmUwZr9VzsFyhO4BZ7gM/azVcrwIPvbITyvnZxh8vxWtP66tqtlel89vpUUTdwi/4aOMLnmn4cx2fp8MrWJcE2SBlrL gcp-adios-key"  

##############################################################################################################################
# BLOCK 3 #  NETWORKING AND NETWORK INTERFACES FOR NODES
# 3.1 SELECTION OF SINGLE AND DUAL NIC AND RELATED CONFIG
##############################################################################################################################

num_nics = 1 # Use 1 for single NIC or 2 for dual NIC. If you need dual NIC, please fill section  # VPC Network for SLI

##############################################################################################################################
# BLOCK 3 #  NETWORKING AND NETWORK INTERFACES FOR NODES
# 3.2 SLO CONFIG 
##############################################################################################################################

slo_vpc_network = "service-vpc"                                     # Add your VPC network name here for SLO
slo_subnetwork_1 = "slo-subnet-1"                                   # Add your Subnetwork/Subnet name here for SLO

##############################################################################################################################
# BLOCK 3 #  NETWORKING AND NETWORK INTERFACES FOR NODES
# 3.2 SLI CONFIG 
# VALUES ARE ONLY CONSUMED IF YOU NEED DUAL NIC AND YOU HAVE GIVEN num_nics = 2
##############################################################################################################################


sli_vpc_network = "service-vpc-sli"                                 # Add your VPC network name here for SLI
sli_subnetwork_1 = "sli-subnet-1"                                   # Add your Subnetwork/Subnet name here for SLI



##############################################################################################################################
# BLOCK 4 # API CREDENTIAL DETAILS , TENANT DETAILS FROM DISTRIBUTED CLOUD
##############################################################################################################################


# These are arguments to supply your api creds for interacting with the XC Tenant
api_p12_file = "sdc-support.console.ves.volterra.io.api-creds.p12"
api_url = "https://sdc-support.console.ves.volterra.io/api"