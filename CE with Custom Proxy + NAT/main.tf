##############################################################################################################################
# BLOCK 1 #  Create SMSV2 site object on XC
##############################################################################################################################
resource "volterra_securemesh_site_v2" "smsv2-site-object" {
  name      = var.cluster_name
  namespace = "system"
  block_all_services = true
  logs_streaming_disabled = true

 # Conditionally set HA based on num_nodes
  # Set HA based on num_nodes
  disable_ha = var.num_nodes == 1 ? true : false
  enable_ha  = var.num_nodes == 3 ? true : false
  

  re_select {
    geo_proximity = true
  }

  gcp {
    not_managed {}
    }
  }

  

##############################################################################################################################
# BLOCK 2 #  Create site token on XC
##############################################################################################################################
resource "volterra_token" "smsv2-token" {
  name      = "${volterra_securemesh_site_v2.smsv2-site-object.name}-token"
  namespace = "system"
  type      = 1
  site_name = volterra_securemesh_site_v2.smsv2-site-object.name

  depends_on = [volterra_securemesh_site_v2.smsv2-site-object]
}
  

##############################################################################################################################
# BLOCK 3 # CREATING THE CE INSTANCE(S) IN GCP
##############################################################################################################################
resource "google_compute_instance" "instance" {
  count        = var.num_nodes # Dynamically create instances based on num_nodes
  name         = "${var.cluster_name}-node-${count.index + 1}"
  machine_type = var.instance_type
  zone         = element(var.az_name, count.index)  # Assigning AZ from the list

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  dynamic "network_interface" {
    for_each = var.num_nics >= 1 ? [1] : []
    content {
      network    = var.slo_vpc_network 
      subnetwork = element(var.slo_subnetwork, count.index)   # Dynamic Subnetwork assignment
      # No access_config block means no public IP
    }
  }

  dynamic "network_interface" {
    for_each = var.num_nics == 2 ? [1] : []
    content {
      network    = var.sli_vpc_network
      subnetwork = element(var.sli_subnetwork, count.index)   # Dynamic SLI Subnetwork assignment
      # No access_config block means no public IP
    }
  }
  
  # Metadata block to include key-value pairs
  metadata = {
    ssh-keys     = "admin:${var.ssh_public_key}" # Direct SSH key in metadata
    VmDnsSetting = "ZonePreferred"                             # Zonal DNS setting
    user-data    = <<-EOT
      #cloud-config
      write_files:
      - path: /etc/vpm/user_data
        content: |
          token: ${volterra_token.smsv2-token.id}
          proxy : ${var.proxy}
        owner: root
        permissions: '0644'
      EOT
  }

  tags = concat(var.tags, ["${var.cluster_name}-node-${count.index + 1}"])

  # Enable IP forwarding
  can_ip_forward = true

  lifecycle {
    create_before_destroy = true
  }
}
