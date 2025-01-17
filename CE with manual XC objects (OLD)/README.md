# 3-Node Customer Edge Deployment Using Terraform (Google Cloud Provider) and with manual XC objects  ( OLD METHOD )

This Terraform configuration deploys three Compute Engine (CE) instances in Google Cloud across different availability zones (AZs) for high availability. Each instance is provisioned with user data and connected to specific subnets within a Virtual Private Cloud (VPC).  
Ref : https://docs.cloud.f5.com/docs-v2/multi-cloud-network-connect/how-to/site-management/deploy-sms-gcp-clickops for clickops

## Prerequisites

Before using this Terraform project, ensure you have the following:
- A Google Cloud Platform (GCP) project
- A service account with permissions for Compute Engine
- Terraform installed on your local machine
- A valid token generated from your Distributed Cloud portal. To see how to generate a valid node token , Follow "Generate Node Token" Section in this [page](https://docs.cloud.f5.com/docs-v2/multi-cloud-network-connect/how-to/site-management/deploy-sms-gcp-clickops)
- SSH key pair for accessing the instances
- Resources required per node: Minimum 4 vCPUs, 14 GB RAM, and 80 GB disk storage.
- Image created in GCP using node image file downloaded from Distributed cloud console. Follow "Import CE Site Image" Section in this [page](https://docs.cloud.f5.com/docs-v2/multi-cloud-network-connect/how-to/site-management/deploy-sms-gcp-clickops)

## Files Overview

### 1. `main.tf`

This file contains the core Terraform resources for:
- Provisioning three Compute Engine instances, each in a different availability zone
- Assigning boot disk configurations, network settings, and metadata
- Writing user data (`token`) to the instance for initialization

### 2. `variables.tf`

Defines the variables used across the Terraform configuration. Key variables include:
- **Project ID and Region:** GCP project and deployment region
- **Cluster Name:** Base name for Compute Engine instances
- **Instance Settings:** Instance type, image, and disk size
- **Networking:** VPC network, subnetworks, and availability zones
- **Metadata:** Token, SSH public key, and tags

### 3. `terraform.tfvars`

This file contains user-specific values for the variables. Key values include:
- GCP project ID and region
- VPC network and subnet IDs for each instance
- Availability zones for high availability
- Compute Engine instance details (e.g., type, image, and disk size)
- SSH public key for instance access
- Token to be written to `/etc/vpm/user_data`

Sample values:
```hcl
project_id    = "f5-gcs-6556-gs-cot04"
region        = "europe-west3"
cluster_name  = "adios-smsv2-google"
instance_type = "n1-standard-4"
image         = "projects/f5-gcs-6556-gs-cot04/global/images/adios-ce-image"
disk_size     = 80
vpc_network   = "service-vpc"
subnetwork_1  = "slo-subnet-1"
subnetwork_2  = "slo-subnet-2"
subnetwork_3  = "slo-subnet-3"
az_name_1     = "europe-west3-a"
az_name_2     = "europe-west3-b"
az_name_3     = "europe-west3-c"
token         = "your-token-here"
tags          = ["f5ce", "adios"]
ssh_public_key = "your-ssh-public-key"
```

## Deployment Steps

### 1. Initialize Terraform
Run the following command to initialize the Terraform project and download the necessary provider plugins:
```bash
terraform init
```

### 2. Plan the Deployment
Preview the resources to be created by running:
```bash
terraform plan
```

### 3. Apply the Configuration
Deploy the infrastructure by applying the Terraform configuration:
```bash
terraform apply
```
Confirm the apply step by typing `yes` when prompted.

### 4. Destroy Resources
To tear down the infrastructure, use:
```bash
terraform destroy
```

## Configuration Details

### Compute Engine Instances
- **Boot Disk:** Each instance is provisioned with an 80GB boot disk using the `pd-standard` disk type.
- **User Data:** A token is written to `/etc/vpm/user_data` for each instance during initialization.
- **Networking:** Instances are connected to a VPC network and individual subnetworks, ensuring isolation and high availability.
- **Tags:** Custom tags are applied to each instance for easy identification and firewall rule application.

### High Availability
Each instance is deployed in a different availability zone:
- `node-1` in `europe-west3-a`
- `node-2` in `europe-west3-b`
- `node-3` in `europe-west3-c`

### Metadata
- SSH keys are provided via instance metadata for secure access.
- DNS settings are configured as "ZonePreferred" for better name resolution within the zone.

## Customization
- **Token and SSH Key:** Update the token and SSH public key in the `terraform.tfvars` file.
- **Instance Type and Image:** Customize the `instance_type` and `image` variables based on your requirements.
- **Tags:** Modify the `tags` variable to include custom labels for your environment.

## Notes
- Ensure that the provided subnets have appropriate routes and firewall rules for the instances to communicate if required.
- Uncomment and configure the proxy settings in `terraform.tfvars` if your environment requires an HTTP proxy.

## Conclusion
This Terraform project provides a semi-automated way to deploy a high-availability 3-node Customer Edge cluster in Google Cloud. Customize the variables as needed and deploy your infrastructure with ease.
