output "deployment_summary" {
  description = "A structured summary of all deployed resources and their key information."
  
  value = {
    # 1. Summary of Inputs
    deployment_model = var.deployment_model
    cluster_name     = var.cluster_name
    node_count       = var.num_nodes
    nic_count        = var.num_nics
    public_ip_mode   = var.ip_configuration.public_ip_assignment_type
    gcp_region       = var.region

    # 2. GCP Compute Outputs
    gcp_instance_ids   = [for instance in google_compute_instance.instance : instance.self_link]
    gcp_instance_zones = [for instance in google_compute_instance.instance : instance.zone]

    # 3. GCP Networking Outputs
    
    # Public IPs (SLO)
    public_ips_slo = var.ip_configuration.public_ip_assignment_type == "CREATE_IP" ? google_compute_address.static_ips[*].address : (var.ip_configuration.public_ip_assignment_type == "EXISTING_IP" ? var.ip_configuration.existing_public_ips : [])
    
    # Private IPs (SLO - Primary Interface, Index 0)
    private_ips_slo = [for instance in google_compute_instance.instance : instance.network_interface[0].network_ip]
    
    # Private IPs (SLI - Secondary Interface, Index 1, only if nic_count is 2)
    private_ips_sli = var.num_nics == 2 ? [for instance in google_compute_instance.instance : instance.network_interface[1].network_ip] : []
    
    created_networks = {
      slo_network = var.slo_vpc_network
      sli_network = var.num_nics == 2 ? var.sli_vpc_network : null
    }

    # 4. F5 XC Outputs
    f5_xc_site_names = [for site in volterra_securemesh_site_v2.smsv2-site-object : site.name]
    f5_xc_virtual_site_name = (
      var.deployment_model == "vsite" ? try(volterra_virtual_site.smsv2-vsite[0].name, "N/A (Vsite Not Created)") : "N/A (Cluster Model)"
    )
  }
}
