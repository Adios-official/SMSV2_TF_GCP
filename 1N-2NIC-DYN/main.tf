##############################################################################################################################
# BLOCK 1 #  Create SMSV2 site object on XC
##############################################################################################################################
resource "volterra_securemesh_site_v2" "smsv2-site-object" {
  name      = var.cluster_name
  namespace = "system"
  block_all_services = true
  logs_streaming_disabled = true
  disable_ha = true
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
# BLOCK 3 # CREATING THE  NODE IN THE 1 NODE CE 
##############################################################################################################################
resource "google_compute_instance" "instance_1" {
  name         = "${var.cluster_name}-node-1"
  machine_type = var.instance_type
  zone         = var.az_name_1

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.slo_vpc_network # Reference to the VPC network
    subnetwork = var.slo_subnetwork_1
    access_config {}
    # No access_config block means no public IP
  }

  network_interface {
    network    = var.sli_vpc_network # Reference to the VPC network
    subnetwork = var.sli_subnetwork_1
    # No access_config block means no public IP
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
        owner: root
        permissions: '0644'
      EOT
  }

  tags = concat(var.tags, ["${var.cluster_name}-node-1"])

  # Enable IP forwarding
  can_ip_forward = true

  lifecycle {
    create_before_destroy = true
  }
}
