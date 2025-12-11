##############################################################################################################################
# 0. INPUT VALIDATIONS
#
# These 'check' blocks validate that variable combinations are correct
# before Terraform attempts to create any resources.
################################################################################

### Deployment Model Consistency ###
check "valid_node_count_for_model" {
  assert {
    condition = (
      (var.deployment_model == "cluster" && contains([1, 3], var.num_nodes)) ||
      (var.deployment_model == "vsite" && var.num_nodes >= 1 && var.num_nodes <= 8)
    )
    error_message = "Invalid node count: For 'cluster' model, num_nodes must be 1 or 3. For 'vsite' model, num_nodes can be 1 to 8."
  }
}

### Public IP Assignment Rules ###
check "valid_ip_configuration" {
  assert {
    condition = (
      # Check 1: If user chose "EXISTING_IP", list must match node count.
      (var.ip_configuration.public_ip_assignment_type == "EXISTING_IP" && length(var.ip_configuration.existing_public_ips) == var.num_nodes) ||
      # Check 2: If user chose "CREATE_IP" or "NONE", list must be empty.
      (var.ip_configuration.public_ip_assignment_type != "EXISTING_IP" && length(var.ip_configuration.existing_public_ips) == 0)
    )
    error_message = "Invalid IP configuration: If public_ip_assignment_type is 'EXISTING_IP', 'existing_public_ips' must contain exactly ${var.num_nodes} IP(s). For 'CREATE_IP' or 'NONE', 'existing_public_ips' must be empty."
  }
}

### Network List Lengths ###
check "valid_list_lengths" {
  assert {
    condition = (
      length(var.az_name) == var.num_nodes &&
      length(var.slo_subnetwork) == var.num_nodes &&
      (var.num_nics == 1 || length(var.sli_subnetwork) == var.num_nodes)
    )
    error_message = <<-EOT
Invalid List Lengths: The number of items in the following lists must match 'num_nodes' (${var.num_nodes}):
- 'az_name' (Count: ${length(var.az_name)})
- 'slo_subnetwork' (Count: ${length(var.slo_subnetwork)})
- 'sli_subnetwork' (Count: ${length(var.sli_subnetwork)}) - Only checked if num_nics=2.
EOT
  }
}

### F5 XC Regional Edge (RE) Selection ###
check "valid_re_configuration" {
  assert {
    condition = (
      (var.re_selection_mode == "auto" && var.primary_re_name == "") ||
      (var.re_selection_mode == "manual" && var.primary_re_name != "")
    )
    error_message = "Invalid RE configuration: If 're_selection_mode' is 'manual', 'primary_re_name' must be set. If 'auto', it must be empty."
  }
}

### GCP Tag Formatting ###
check "valid_gcp_tags" {
  assert {
    # Check 1: Ensure all tags are lowercase. GCP tags must be lowercase.
    condition = alltrue([
      for tag in var.tags : can(regex("^[a-z0-9-]{1,63}$", tag))
    ])
    error_message = "Invalid GCP tags: All tags must be lowercase, contain only alphanumeric characters or hyphens (-), and be between 1 and 63 characters long. Uppercase letters are not allowed."
  }
}

### Service Account Consistency ###
check "service_account_consistency" {
  assert {
    condition = (
      (var.service_account_email != "" && length(var.gcp_service_account_scopes) > 0) ||
      (var.service_account_email == "" && length(var.gcp_service_account_scopes) == 0)
    )
    error_message = "Service Account configuration error: If 'service_account_email' is provided, 'gcp_service_account_scopes' must contain at least one scope. If 'service_account_email' is blank, 'gcp_service_account_scopes' must be an empty list ([])."
  }
}

### VPC Network Name Check ###
check "network_names_must_be_set" {
  assert {
    condition = (
      var.slo_vpc_network != "" &&
      (var.num_nics == 1 || var.sli_vpc_network != "")
    )
    error_message = "Network Configuration Error: 'slo_vpc_network' must be set. If 'num_nics' is 2, 'sli_vpc_network' must also be set."
  }
}

### Static Route Next Hop Check ###
check "static_route_next_hop_required" {
  assert {
    condition = (
      (var.vrf_config.slo_network_mode != "static" || (length(var.vrf_config.static_route_prefixes_slo) == 0 || var.vrf_config.static_route_next_hop_slo != "")) &&
      (var.vrf_config.sli_network_mode != "static" || (length(var.vrf_config.static_route_prefixes_sli) == 0 || var.vrf_config.static_route_next_hop_sli != ""))
    )
    error_message = "Static Route Error: If 'slo_network_mode' or 'sli_network_mode' is 'static' and prefixes are provided, the corresponding 'static_route_next_hop' field cannot be empty."
  }
}

### SSH Key Format Check ###
check "valid_ssh_public_key_format" {
  assert {
    condition = (
      var.ssh_public_key == "" || 
      can(regex("^(ssh-rsa|ecdsa-sha2-nistp256|ssh-ed25519) [A-Za-z0-9+/=]+.*$", var.ssh_public_key))
    )
    error_message = "Invalid SSH public key format: Key must start with 'ssh-rsa', 'ecdsa-sha2-nistp256', or 'ssh-ed25519' followed by the key content. Leave blank if optional."
  }
}
##############################################################################################################################
# BLOCK 1 # F5 XC VIRTUAL SITE LABELS
##############################################################################################################################

resource "volterra_known_label_key" "smsv2-vsite_key" {
  count = var.deployment_model == "vsite" ? 1 : 0

  key         = "${var.cluster_name}-vsite"
  namespace   = "shared"
  description = "key used for v-site creation"
}

resource "volterra_known_label" "smsv2-vsite_label" {
  count = var.deployment_model == "vsite" ? 1 : 0

  key         = volterra_known_label_key.smsv2-vsite_key[0].key
  namespace   = "shared"
  value       = "true"
  description = "label used for v-site creation"
  depends_on  = [volterra_known_label_key.smsv2-vsite_key]
}


##############################################################################################################################
# BLOCK 2 # GCP STATIC IPs
##############################################################################################################################

resource "google_compute_address" "static_ips" {
  # This creates IPs only if the user selected CREATE_IP.
  count  = var.ip_configuration.public_ip_assignment_type == "CREATE_IP" ? var.num_nodes : 0
  name   = "static-ip-${count.index + 1}"
  region = var.region
  network_tier = var.network_tier
}

##############################################################################################################################
# BLOCK 3 # CREATING THE CE INSTANCE(S) IN GCP
##############################################################################################################################
resource "google_compute_instance" "instance" {
  count          = var.num_nodes
  name           = "${var.cluster_name}-node-${count.index + 1}"
  machine_type   = var.instance_type
  zone           = element(var.az_name, count.index)

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-balanced" # Using pd-balanced for better performance
    }
  }

  # 1. Primary Interface (SLO / eth0)
  dynamic "network_interface" {
    for_each = var.num_nics >= 1 ? [1] : []
    content {
      network    = var.slo_vpc_network
      subnetwork = element(var.slo_subnetwork, count.index)
      
      # Conditionally add Public IP (access_config) if not "NONE"
      dynamic "access_config" {
        for_each = var.ip_configuration.public_ip_assignment_type != "NONE" ? [1] : [] 
        content {
          # Use EXISTING_IPs if provided, otherwise use the newly created static IPs (CREATE_IP)
          nat_ip       = var.ip_configuration.public_ip_assignment_type == "EXISTING_IP" ? var.ip_configuration.existing_public_ips[count.index] : google_compute_address.static_ips[count.index].address
          network_tier = var.network_tier
        }
      }
    }
  }

  # 2. Secondary Interface (SLI / eth1)
  dynamic "network_interface" {
    for_each = var.num_nics == 2 ? [1] : []
    content {
      network    = var.sli_vpc_network
      subnetwork = element(var.sli_subnetwork, count.index)
      # No access_config block means no public IP
    }
  }
  

# --- METADATA (Security, Troubleshooting, and Token Injection) ---
  metadata = merge(
    {
      # Networking: Prioritize zonal DNS for consistency
      VmDnsSetting               = "ZonePreferred"
      
      # Security: Enable OS Login to centralize access via IAM roles
      "enable-oslogin"           = "TRUE" 
      
      # Security: Prevent project-wide keys from being injected
      "block-project-ssh-keys"   = "TRUE" 
      
      # Security: Disable legacy metadata endpoint access to prevent token theft
      "disable-legacy-endpoints" = "TRUE"
      
      # Operations: Enable serial port for out-of-band debugging (HIGHLY RECOMMENDED)
      "serial-port-enable"       = "TRUE"

      # F5 XC Initialization: User-data to inject the registration token
      user-data = <<-EOT
      #cloud-config
      write_files:
      - path: /etc/vpm/user_data
        content: |
          # Conditional token selection: [0] for cluster, [count.index] for vsite
          token: ${var.deployment_model == "cluster" ? volterra_token.smsv2-token[0].id : volterra_token.smsv2-token[count.index].id}
        owner: root
        permissions: '0644'
      EOT
    },
    # Use a 'for' expression to build a temporary map that is either empty ({}) or contains the ssh-keys entry.
    # This avoids adding any placeholder key.
    {
      for key, value in { "ssh-keys" = "admin:${var.ssh_public_key}" } : key => value
      if var.ssh_public_key != ""
    }
  )

  # The block is created if the user provides an email, otherwise it is omitted.
  dynamic "service_account" {
    for_each = var.service_account_email != "" ? [1] : []
    content {
      email  = var.service_account_email
      # Use the user-defined scopes
      scopes = var.gcp_service_account_scopes 
    }
  }

  tags = concat(
    var.tags, 
    ["${var.cluster_name}-node-${count.index + 1}"],
    # NEW TAG used for firewall rules 
    ["${var.cluster_name}-ce-node"]
  )
  can_ip_forward = true

  lifecycle {
    create_before_destroy = true
  }
  
  # Dependency added for the token ID injection
  depends_on = [volterra_token.smsv2-token]
}


##############################################################################################################################
# BLOCK 4 # GCP FIREWALL RULES (F5 XC Connectivity)
##############################################################################################################################

# Rule 1: Allow required inbound connectivity for F5 XC (SLO/SLI traffic and management).
resource "google_compute_firewall" "f5xc_ingress_rules" {
  # CONDITIONAL CREATION: Only create if var.create_firewall_rules is true 
  count   = var.create_firewall_rules ? 1 : 0
  
  name    = "${var.cluster_name}-f5xc-ingress"
  network = var.slo_vpc_network # Apply to the network where the primary interface (SLO) lives

  # The rule applies to the F5 CE instances using the common tag
  target_tags = ["${var.cluster_name}-ce-node"]
  direction   = "INGRESS"

  # Traffic is allowed from all external IPs (0.0.0.0/0)
  source_ranges = ["0.0.0.0/0"]

  # TCP Ports: 80 (HTTP), 443 (HTTPS/Control Plane)
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # UDP Ports: 123 (NTP), 4500 (IPsec/Tunneling)
  allow {
    protocol = "udp"
    ports    = ["123", "4500"]
  }
}

# Rule 2: Allow all required outbound traffic (Control Plane, DNS, etc.)
resource "google_compute_firewall" "f5xc_egress_all" {
  # CONDITIONAL CREATION: Only create if var.create_firewall_rules is true 
  count   = var.create_firewall_rules ? 1 : 0

  name    = "${var.cluster_name}-f5xc-egress"
  network = var.slo_vpc_network

  # The rule applies to the F5 CE instances using the common tag
  target_tags = ["${var.cluster_name}-ce-node"]
  direction   = "EGRESS"

  # Allow all outbound traffic to all destinations (0.0.0.0/0)
  destination_ranges = ["0.0.0.0/0"]

  # Allow all protocols
  allow {
    protocol = "all"
  }
}


##############################################################################################################################
# BLOCK 5 # F5 XC SITE & TOKEN
##############################################################################################################################

resource "volterra_securemesh_site_v2" "smsv2-site-object" {
  # 1. Conditional Count Logic 
  count     = var.deployment_model == "vsite" ? var.num_nodes : 1 
  
  # 2. Conditional Naming Logic 
  name      = var.deployment_model == "vsite" ? "${var.cluster_name}-${count.index + 1}" : var.cluster_name
  namespace = "system"
  
  # 3. Conditional Labels 
  labels    = var.deployment_model == "vsite" ? { (volterra_known_label.smsv2-vsite_label[0].key) = (volterra_known_label.smsv2-vsite_label[0].value) } : {}

  # 4. Conditional HA Logic 
  disable_ha = var.deployment_model == "vsite" || (var.deployment_model == "cluster" && var.num_nodes == 1)
  enable_ha  = var.deployment_model == "cluster" && var.num_nodes == 3
  
  block_all_services    = true
  logs_streaming_disabled = true

# Conditional RE selection based on mode (auto/manual)
  re_select {
    
    # 1. AUTO MODE: Set geo_proximity to TRUE if the user chooses 'auto'.
    geo_proximity = var.re_selection_mode == "auto" ? true : null
    
    # 2. MANUAL MODE: Conditionally include the specific_re (Object) block.
    dynamic "specific_re" {
      # This block is only created if the user selects "manual"
      for_each = var.re_selection_mode == "manual" ? [1] : []
      content {
        primary_re = var.primary_re_name
      }
    }
  }

  # --- GCP CONFIGURATION (Complex Interface Logic ) ---
gcp {
    not_managed {
      dynamic "node_list" {
        # Outer loop: Iterates over all nodes based on deployment model
        for_each = var.deployment_model == "cluster" ? range(var.num_nodes) : [count.index]

        content {
          
          # Hostname uses only static input variables to break the cycle 
          hostname = "${var.cluster_name}-node-${node_list.value + 1}"
          type     = "Control"

dynamic "interface_list" {
            # Inner loop: Runs 1 (for eth0/ens4) or 2 (for eth0/ens4, eth1/ens5) times
            for_each = range(var.num_nics)

            content {
              #-------------------------------------------------------------------------------
              # ❗ IMPORTANT NOTE ON F5 XC GCP INTERFACE MAPPING:
              #
              # Confirmed Mapping for this GCP environment: interfaces are ens4 and ens5.
              # "ens4": **Site Local Outside (SLO)**
              # "ens5": **Site Local Inside (SLI)**
              #-------------------------------------------------------------------------------
              
              # --- Core Fields ---
              # Using the confirmed device names (ens4/ens5) for the name field.
              name       = interface_list.value == 0 ? "ens4" : "ens5" 
              priority   = 0
              mtu        = 0
              dhcp_client = true 

              # --- Blocks for interface core config ---
              ethernet_interface {
                # Linux Device Name inside the VM (ens4/ens5)
                device = interface_list.value == 0 ? "ens4" : "ens5"
              }

              

              network_option {
                
                # Interface 0 (ens4/SLO): site_local_network is TRUE
                site_local_network = interface_list.value == 0
                
                # Interface 1 (ens5/SLI): site_local_inside_network is TRUE
                site_local_inside_network = interface_list.value == 1
              }
            }
          }
        
        }
      }
    }
  }

local_vrf {
    
    # --- SLI VRF Configuration (Site Local Inside) ---
    default_sli_config = var.vrf_config.sli_network_mode == "default" ? true : null
    
    dynamic "sli_config" {
      for_each = var.vrf_config.sli_network_mode == "static" ? [1] : []
      content {
        # Optional DNS setting (omitted if blank)
        nameserver = var.vrf_config.nameserver_sli != "" ? var.vrf_config.nameserver_sli : null
        
        # Static Route Choice:
        no_static_routes = var.vrf_config.static_route_prefixes_sli == [] ? true : null
        
        dynamic "static_routes" {
          for_each = var.vrf_config.static_route_prefixes_sli != [] ? [1] : []
          content {
            static_routes {
              ip_prefixes = var.vrf_config.static_route_prefixes_sli
              ip_address = var.vrf_config.static_route_next_hop_sli
              attrs = [ "ROUTE_ATTR_INSTALL_HOST","ROUTE_ATTR_INSTALL_FORWARDING" ]
            }
          }
        }
        no_v6_static_routes = true 
        
      }
    }
    
    # --- SLO VRF Configuration (Site Local Outside) ---
    default_config = var.vrf_config.slo_network_mode == "default" ? true : null
    
    dynamic "slo_config" {
      for_each = var.vrf_config.slo_network_mode == "static" ? [1] : []
      content {
        # Optional DNS setting (omitted if blank)
        nameserver = var.vrf_config.nameserver_slo != "" ? var.vrf_config.nameserver_slo : null
        
        # Static Route Choice:
        no_static_routes = var.vrf_config.static_route_prefixes_slo == [] ? true : null

        dynamic "static_routes" {
          for_each = var.vrf_config.static_route_prefixes_slo != [] ? [1] : []
          content {
            static_routes {
              ip_prefixes = var.vrf_config.static_route_prefixes_slo
              ip_address = var.vrf_config.static_route_next_hop_slo
              attrs = [ "ROUTE_ATTR_INSTALL_HOST","ROUTE_ATTR_MERGE_ONLY" ]
            }
          }
        }
        no_v6_static_routes = true 
      }
    }
  }
  
  lifecycle {
    ignore_changes = [ labels ]
  }
  
  # Uses static list reference to optional resources dependencies
  # If count is 0, the dependency is safely ignored by the graph solver.
  depends_on = [
    volterra_known_label.smsv2-vsite_label,
    google_compute_firewall.f5xc_ingress_rules, 
    google_compute_firewall.f5xc_egress_all, 
  ]
}

# Create a registration token for each site object
resource "volterra_token" "smsv2-token" {
  count = var.deployment_model == "vsite" ? var.num_nodes : 1

  name      = var.deployment_model == "vsite" ? "${volterra_securemesh_site_v2.smsv2-site-object[count.index].name}-token" : "${volterra_securemesh_site_v2.smsv2-site-object[0].name}-token"
  namespace = "system"
  type      = 1
  site_name = volterra_securemesh_site_v2.smsv2-site-object[count.index].name

  depends_on = [volterra_securemesh_site_v2.smsv2-site-object]
}


##############################################################################################################################
# BLOCK 6 # F5 XC VIRTUAL SITE
##############################################################################################################################

resource "volterra_virtual_site" "smsv2-vsite" {
  count = var.deployment_model == "vsite" ? 1 : 0

  name      = "${var.cluster_name}-vsite"
  namespace = "shared"
  site_type = "CUSTOMER_EDGE"
  
  site_selector {
    expressions = ["${var.cluster_name}-vsite in (true)"]
  }

  depends_on = [
    volterra_known_label.smsv2-vsite_label
  ]
}
