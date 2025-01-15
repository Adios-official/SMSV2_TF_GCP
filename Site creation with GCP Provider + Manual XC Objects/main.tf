##############################################################################################################################
# BLOCK 1 # PROVIDER BLOCK FOR GCP PROVIDER
##############################################################################################################################

provider "google" {
  project = var.project_id
  region  = var.region
}

##############################################################################################################################
# BLOCK 2 # CREATING THE FIRST NODE IN THE 3 NODE CE 
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
    network    = var.vpc_network # Reference to the VPC network
    subnetwork = var.subnetwork_1
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
          token: ${var.token}
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
##############################################################################################################################
# BLOCK 3 # CREATING THE SECOND NODE IN THE 3 NODE CE 
##############################################################################################################################
resource "google_compute_instance" "instance_2" {
  name         = "${var.cluster_name}-node-2"
  machine_type = var.instance_type
  zone         = var.az_name_2

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.vpc_network # Reference to the VPC network
    subnetwork = var.subnetwork_2
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
          token: ${var.token}
        owner: root
        permissions: '0644'
      EOT
  }

  tags = concat(var.tags, ["${var.cluster_name}-node-2"])

  depends_on = [google_compute_instance.instance_1]

  can_ip_forward = true

  lifecycle {
    create_before_destroy = true
  }
}

##############################################################################################################################
# BLOCK 4 # CREATING THE THIRD NODE IN THE 3 NODE CE 
##############################################################################################################################
resource "google_compute_instance" "instance_3" {
  name         = "${var.cluster_name}-node-3"
  machine_type = var.instance_type
  zone         = var.az_name_3

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.vpc_network # Reference to the VPC network
    subnetwork = var.subnetwork_3
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
          token: ${var.token}
        owner: root
        permissions: '0644'
      EOT
  }

  tags = concat(var.tags, ["${var.cluster_name}-node-3"])

  depends_on = [google_compute_instance.instance_2]

  can_ip_forward = true

  lifecycle {
    create_before_destroy = true
  }
}
