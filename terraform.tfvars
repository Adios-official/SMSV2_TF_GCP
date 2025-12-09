################################################################################
# 1. F5 DISTRIBUTED CLOUD (XC) API CREDENTIALS
################################################################################

# Path to your F5 XC API credential file (required for Volterra provider)
api_p12_file = "path/to/f5xc-api-creds.p12"

# URL for the F5 XC API endpoint
api_url = "https://your-tenant-name.console.ves.volterra.io/api"

################################################################################
# 2. DEPLOYMENT MODEL & SITE CONFIGURATION
################################################################################

# The logical deployment model. Options: "cluster" or "vsite"
# - "cluster": Creates 1 XC site object. HA is enabled if num_nodes = 3.
# - "vsite":   Creates 1 XC site object PER NODE, grouped by a single virtual_site.
deployment_model = "vsite"

#-------------------------------------------------------------------------------
# IMPORTANT NOTE ON DEPLOYMENT MODEL:
#
# "cluster": Use this for a standard single-site or 3-node HA deployment.
#   - 1 or 3 nodes.
#   - 1 `volterra_securemesh_site_v2` resource.
#   - 1 `volterra_token` (shared by all nodes).
#
# "vsite": Use this to deploy multiple, independent nodes as a single logical group.
#   - 1 to 8 nodes (module constraint).
#   - Creates `num_nodes` (e.g., 2) `volterra_securemesh_site_v2` resources.
#   - Creates `num_nodes` (e.g., 2) `volterra_token` resources (one per node).
#   - Creates 1 `volterra_virtual_site` to group them all.
#-------------------------------------------------------------------------------

# Base name for the site(s) and GCP resources. Must be a valid DNS-1035 label.
cluster_name = "gcp-ha-site-example"

# Number of CE nodes to deploy.
# - If deployment_model = "cluster", must be 1 or 3.
# - If deployment_model = "vsite", can be 1 to 8 (module constraint is currently 1-3).
num_nodes = 3

# Number of network interfaces (NICs) per node.
# - 1 = Single-NIC (SLO only)
# - 2 = Dual-NIC (SLO + SLI)
num_nics = 2

# --- Regional Edge (RE) Selection ---
# Controls how the RE is selected. Options: 'auto' (geo_proximity) or 'manual' (specific_re).
re_selection_mode = "manual"

# The name of the specific Regional Edge to use when re_selection_mode is 'manual'.
# Must be empty if mode is 'auto'.
primary_re_name = "ves-io-stockholm"

################################################################################
# 3. GCP COMPUTE & IMAGE CONFIGURATION
################################################################################

# The GCP project ID where nodes and networks reside.
project_id = "gcp-f5xc-deployment-project"

# GCP Region where resources will be deployed
region = "europe-west3"

# GCP Machine Type (e.g., "n2-standard-8" is min spec for medium node)
# (Ref: https://docs.cloud.f5.com/docs-v2/multi-cloud-network-connect/reference/ce-site-size-ref)
instance_type = "n2-standard-8"

# Full Location to the Custom GCP Image for the F5 XC CE nodes.
# Must be a valid image path (e.g., "projects/PROJECT_ID/global/images/IMAGE_NAME")
image = "projects/gcp-f5xc-deployment-project/global/images/f5xc-ce-image-v2025"

# Root disk size in GB (120 GB is minimum)
disk_size = 120

# SSH public key content for injecting into instance metadata (used for access).
ssh_public_key = "ssh-rsa AAAA...my-public-key-content...gcp-deploy-key"

# Custom network tags to apply to all created GCP resources
tags = ["prod-env", "f5xc-ce"]

################################################################################
# 4. GCP NETWORKING & SECURITY CONFIGURATION
################################################################################

# --- Availability Zones ---
# List of zones where nodes will be deployed.
# NOTE: The number of items in this list MUST match 'num_nodes'.
az_name = [
  "europe-west3-a", # For node-1
  "europe-west3-b", # For node-2
  "europe-west3-c"  # For node-3
]

# --- SLO Network (Primary Interface) ---
# VPC and Subnet network paths for the SLO (Primary) interface.
# NOTE: The number of items in 'slo_subnetwork' MUST match 'num_nodes'.
slo_vpc_network = "xc-service-vpc"
slo_subnetwork = [
  "slo-subnet-node1", # For node-1
  "slo-subnet-node2", # For node-2
  "slo-subnet-node3"  # For node-3
]

# --- SLI Network (Secondary Interface - Used if num_nics=2) ---
# VPC and Subnet network paths for the SLI (Secondary) interface.
# NOTE: The number of items in 'sli_subnetwork' MUST match 'num_nodes' if num_nics = 2.
sli_vpc_network = "xc-workload-vpc"
sli_subnetwork = [
  "sli-subnet-node1", # For node-1
  "sli-subnet-node2", # For node-2
  "sli-subnet-node3"  # For node-3
]
#-------------------------------------------------------------------------------
# NOTE ON SLI SUBNETWORK:
# If 'num_nics' is set to 1, the 'sli_vpc_network' and 'sli_subnetwork'
# settings are safely ignored. Terraform logic will not attempt to configure
# the secondary NIC if 'num_nics = 1'.
#-------------------------------------------------------------------------------

# --- Public IP Assignment & Tier ---
# The network tier for the Public IP ('STANDARD' or 'PREMIUM').
network_tier = "STANDARD"

# Configuration object for Public IP assignment.
ip_configuration = {
  # Assignment Method: "CREATE_IP", "EXISTING_IP", or "NONE".
  public_ip_assignment_type = "CREATE_IP"
  
  # List of existing Public IP addresses.
  # Must be empty if public_ip_assignment_type is "CREATE_IP" or "NONE".
  existing_public_ips = [] 
}

# Firewall Rule Switch: true to create default F5 XC ingress/egress rules, false to skip.
create_firewall_rules = true
