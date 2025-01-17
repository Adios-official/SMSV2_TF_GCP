#########################################################################################################
# OUTPUTS.TF
#########################################################################################################
output "allocated_public_ips_to_SLO" {
  description = "List of public IPs allocated to the instances."
  value = var.ip_configuration.public_ip_assignment_type == "STATIC_NEW" && length(google_compute_address.static_ips) > 0 ? [google_compute_address.static_ips[0].address] :var.ip_configuration.existing_public_ips
}

