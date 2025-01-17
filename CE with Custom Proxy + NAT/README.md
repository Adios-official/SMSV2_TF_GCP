# Customer Edge (CE) with Custom Proxy + NAT

## Overview

This folder contains Terraform configurations to deploy a Customer Edge (CE) in GCP with custom proxy and NAT configurations. It dynamically handles deployments for:

- Single-node CE or High Availability (HA) CE with three nodes.
- Single NIC or dual NIC setups.

This setup integrates with Volterra (F5 Distributed Cloud) and GCP, making it suitable for environments requiring secure and scalable edge deployments.

## Folder Structure and Key Files

### 1. `main.tf`

This file defines the main resources:

- `volterra_securemesh_site_v2`: Creates a site object in Volterra.
- `volterra_token`: Generates a site token for provisioning.
- `google_compute_instance`: Provisions CE instances in GCP based on the specified configurations.

**Key Features:**

- Dynamically manages instance count and NIC configuration based on variables (`num_nodes`, `num_nics`).
- Customizes network interface assignments (SLO and SLI traffic).
- Includes metadata for SSH keys and user data (e.g., proxy settings, site token).
- Ensures proper configurations for instance count, network interfaces, and other critical settings to avoid misconfigurations. This includes checking the number of nodes, network assignments, and subnet configurations to align with GCP and Volterra requirements.
- A `proxy` variable is included in the `terraform.tfvars` file. This variable should be populated with your proxy settings if your architecture requires a proxy for network traffic routing. It will be applied accordingly in the configuration.

### 2. `provider.tf`

This file specifies the providers required for the deployment:

- **Google Cloud Platform (google)**: Manages GCP resources.
- **Volterra (volterra)**: Integrates with Volterra APIs for site creation and token generation.

### 3. `terraform.tfvars`

This file contains user-defined values for variables. Update this file with your specific project details and configuration, such as:

- GCP project ID, region, and instance settings.
- Network configurations (VPC, subnets, availability zones).
- Volterra API credentials and proxy settings.

### 4. `variables.tf`

This file declares and validates variables used across the configuration. Key variables include:

- **Basic Configuration**: `project_id`, `region`, `cluster_name`, `instance_type`, etc.
- **Network Settings**: `slo_vpc_network`, `slo_subnetwork`, `sli_vpc_network`, `sli_subnetwork`.
- **Availability Zones**: `az_name` (supports up to 3 zones for HA setups).

## Usage Instructions

### 1. Prerequisites

- Install Terraform (v1.3.0 or later).
- Have GCP project and credentials ready.
- Obtain Volterra API credentials (`.p12` file and API URL).

### 2. Configuration Steps

Update the `terraform.tfvars` file with:

- GCP project details (`project_id`, `region`, `instance_type`, etc.).
- Desired cluster configuration (e.g., single or HA CE, single or dual NIC).
- Networking information (VPC, subnets, availability zones).
- SSH public key for node access.
- Ensure the Volterra API credentials (`api_p12_file`, `api_url`) are available and correctly configured.
- If required, provide proxy settings in the `proxy` variable.

### 3. Deployment Steps

- Initialize the Terraform working directory:
  ```bash
  terraform init

- Validate the configuration:
  ```bash
  terraform validate

- Preview the planned infrastructure changes:
  ```bash
  terraform plan

- Apply the configuration to create resources:
  ```bash
  terraform apply

### 4. Post-Deployment

- Verify the created CE instances in the GCP console.
- Validate the Volterra site object and token.

## Notes and Considerations

- Ensure the subnets and availability zones align with your desired architecture.
- For dual NIC setups, both `slo_subnetwork` and `sli_subnetwork` must have values for each node.
- Proxy settings should be configured only if required by your network setup.
- High Availability (HA) mode automatically enables when `num_nodes` is set to 3.
- **No more than one network interface for a node should be on the same subnet**: In GCP, it is recommended to avoid placing multiple interfaces for the same node on the same subnet. This ensures proper network segmentation, prevents routing issues, and aligns with GCP's best practices for isolating traffic between different interfaces.

For any issues or further assistance, please contact your F5 representative or refer to the Volterra and GCP documentation.

  
  
