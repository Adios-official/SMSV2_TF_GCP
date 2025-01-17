##############################################################################################################################
# BLOCK 1 #  GCP BASIC VARIABLES
##############################################################################################################################

# GCP Project ID - unique project ID from GCP that can be a combination of letters, numbers, and hyphens
# CHANGE THIS
project_id = "xxxxxxxx"

# GCP Region
# CHANGE THIS
region = "europe-west3" # Change as necessary



##############################################################################################################################
# BLOCK 2 #  BASIC VARIABLES FOR CE 
# GCP Instance Information - Resources required per node: Minimum 4 vCPUs, 14 GB RAM, and 80 GB disk storage
# CHANGE THESE VALUES AS PER YOUR USE-CASE
##############################################################################################################################
cluster_name    = "adios-tf-3node-2nic"              # Name for the customer Edge ( Each node will take this name followed by suffix like node-1, node-2 etc. )
instance_type   = "n1-standard-4"                                              # Change as necessary
image           = "projects/xxxxxxx/global/images/xc-ce-image"                 # Use a suitable image
disk_size       = 80                                                           # Disk size in GB. 80 GB is minimum.
# Directly add your public key. This would be SSH key for Command line access to the nodes.
ssh_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ....your-key-here"  
num_nics        = 2                               # Use 1 for single NIC or 2 for dual NIC. If you need dual NIC, please fill section  # VPC Network for SLI
num_nodes       = 3                               # Choose if you need a Single Node CE or an HA CE with 3 Nodes
tags            = ["TAG-1", "TAG-2"]               # Tags you would like to add to the nodes in the CE cluster. 



##############################################################################################################################
# BLOCK 3 #  NETWORKING AND NETWORK INTERFACES FOR NODES
# 3.1 SLO CONFIG 
# Provide distinct SLO subnet values for each node if 3 nodes
# Carefully choose the public_ip_assignment type
##############################################################################################################################

# Add your VPC network name here for SLO
slo_vpc_network = "service-vpc"    

# Add your Subnetwork/Subnet name here for SLO, 1 for each node in case  of 3 nodes. For 1 node just 1 value is enough in the list.
slo_subnetwork = [
  "slo-subnet-1",
  "slo-subnet-2",
  "slo-subnet-3"
]  

##############################################################################################################################
# BLOCK 3 #  NETWORKING AND NETWORK INTERFACES FOR NODES
# 3.2 SLI CONFIG 
# VALUES ARE ONLY CONSUMED IF YOU NEED DUAL NIC AND YOU HAVE GIVEN num_nics = 2
# Provide distinct SLI subnet values for each node if 3 nodes
##############################################################################################################################

# Add your VPC network name here for SLI
sli_vpc_network = "service-vpc-sli"  

# Add your Subnetwork/Subnet name here for SLI, 1 for each node in case of 3 nodes. For 1 node just 1 value is enough in the list.
sli_subnetwork = [
  "sli-subnet-1",
  "sli-subnet-2",
  "sli-subnet-3"
]                                 

##############################################################################################################################
# BLOCK 4 # AVAILABILITY ZONE DETAILS , TENANT DETAILS FROM DISTRIBUTED CLOUD
# Provide distinct Availability zone values for each node if 3 nodes
##############################################################################################################################

# Add your Availability zone names here, 1 for each node in case of 3 nodes. For 1 node just 1 value is enough in the list.
az_name = [
  "europe-west3-a",
  "europe-west3-b",
  "europe-west3-c"
]

##############################################################################################################################
# BLOCK 5 # PROXY SETTINGS
##############################################################################################################################
# This will feed into the CE as outbound proxy for connections 
# Used for initial CE provisioning 
#( Uncomment PROXY only if you have an enterprise proxy in your Architecture. Please discuss with the F5 Engineer.)
proxy = "http://your-proxy-here:port"


##############################################################################################################################
# BLOCK 6 # API CREDENTIAL DETAILS , TENANT DETAILS FROM DISTRIBUTED CLOUD
##############################################################################################################################


# These are arguments to supply your api creds for interacting with the XC Tenant
api_p12_file = "XXXXXXXX.console.ves.volterra.io.api-creds.p12"
api_url = "https://XXXXXXXX.console.ves.volterra.io/api"


