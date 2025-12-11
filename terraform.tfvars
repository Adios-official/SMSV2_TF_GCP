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
cluster_name = "example-gcp-site-01"

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
project_id = "gcp-f5xc-deployment-project-id"

# GCP Region where resources will be deployed
region = "europe-west3"

# GCP Machine Type (e.g., "n2-standard-8" is min spec for medium node)
# (Ref: https://docs.cloud.f5.com/docs-v2/multi-cloud-network-connect/reference/ce-site-size-ref)
instance_type = "n2-standard-8"

# Full Location to the Custom GCP Image for the F5 XC CE nodes.
# Must be a valid image path (e.g., "projects/PROJECT_ID/global/images/IMAGE_NAME")
image = "projects/gcp-f5xc-deployment-project-id/global/images/f5xc-ce-image-v2025"

# Root disk size in GB (120 GB is minimum)
disk_size = 120

# OPTIONAL : SSH public key content (used for access).
# WARNING: Replace with your actual public key content if direct SSH access is needed.
ssh_public_key = "ssh-rsa AAAA...your-public-key-content...gcp-deploy-key"

# OPTIONAL : Custom network tags to apply to all created GCP resources
#tags = ["tag-1", "tag-2"]
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

################################################################################
# 5. GCP FIREWALL RULES CONFIGURATION (Optional) leave as is if not used
################################################################################
# Firewall Rule Switch: true to create default F5 XC ingress/egress rules, false to skip.
create_firewall_rules = false

# NOTE ON FIREWALL RULES:
# These ingress/egress rules (if set to true) are highly permissive and are intended 
# only for a basic F5 XC connection establishment. They allow traffic from 
# 0.0.0.0/0 to the CE nodes on required ports (443, 80, 4500, 123) and allow ALL 
# outbound traffic (0.0.0.0/0). 
# 
# For production environments, these rules must be replaced or refined with 
# strict Source IP Ranges (e.g., only F5 XC RE IPs) and constrained egress policies.

################################################################################
# 6. F5 XC VRF STATIC ROUTE CONFIGURATION (Optional) leave as is if not used
################################################################################

vrf_config = {
  # SLO network mode: "default" (no custom routes/DNS) or "static"
  slo_network_mode = "default" 
  # SLI network mode: "default" (no custom routes/DNS) or "static"
  sli_network_mode = "default" 

  # --- SLO STATIC ROUTE CONFIG (Used if slo_network_mode = "static") ---
  # Only one next-hop type is supported here: IP Address.
  static_route_prefixes_slo = [] # e.g., ["10.10.0.0/16"]
  static_route_next_hop_slo = "" # e.g., "192.168.10.1" (Next hop IP)
  
  # --- SLI STATIC ROUTE CONFIG (Used if sli_network_mode = "static") ---
  static_route_prefixes_sli = [] # e.g., ["10.10.10.0/24"]
  static_route_next_hop_sli = "" # e.g., "10.10.10.1" (Next hop IP)

  # Optional DNS (Applies only if the mode is "static" and you need custom DNS)
  nameserver_sli = "" # e.g., "1.1.1.1"
  nameserver_slo = "" # e.g., "8.8.8.8"
}

###############################################################################
# 7. SERVICE ACCOUNT CONFIGURATION (Optional) leave as is if not used
################################################################################

# --- SERVICE ACCOUNT (FOR VM IDENTITY) ---
# Email address of the Service Account to attach to the VM instance. 
# EXAMPLE FORMAT : xc-ce-sa@gcp-project-id.iam.gserviceaccount.com
service_account_email = ""

# List of scopes granted to the Service Account. This authorizes the VM to try and access APIs.
# example : Minimal Scope: compute.readonly. (https://www.googleapis.com/auth/compute.readonly)
# example : Highly Permissive Scope: cloud-platform.(https://www.googleapis.com/auth/cloud-platform)
gcp_service_account_scopes = []
