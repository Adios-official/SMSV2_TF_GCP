# Multi-Deployment Customer Edge (CE) Solutions Using Terraform on Google Cloud

This repository contains multiple Terraform configurations to deploy **Customer Edge (CE)** instances in Google Cloud, each designed to cater to different use cases. The configurations are organized into three distinct folders based on the deployment method, which are as follows:

- **CE with Custom Proxy + NAT**
- **CE with Public SLO IP**
- **CE with Manual XC Objects (Old Method)**

Each folder contains a specific Terraform configuration that deploys a high-availability 3-node Customer Edge (CE) solution in Google Cloud, with varying requirements for network configuration and proxy setups.

## Folder Structure

```plaintext
.
├── ce-with-custom-proxy-nat/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── README.md
│   └── ...
├── ce-with-public-slo-ip/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── README.md
│   └── ...
└── ce-with-manual-xc-objects/
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── terraform.tfvars
    ├── variables.tf
    ├── README.md
    └── ...
```
## What Each Folder Contains

### 1. **`ce-with-custom-proxy-nat/`**
This folder contains the Terraform configuration for deploying **Customer Edge (CE)** with custom proxy settings and NAT functionality. The instances in this setup are configured with network interfaces and access through a proxy server. 
- **Use case**: Choose this configuration if your infrastructure requires custom proxy configurations for HTTP traffic and NAT for outbound traffic.
- **Key Features**:
  - Custom proxy settings available in `terraform.tfvars`.
  - Assumption here is that the customer end NAT is configured to route outbound traffic through an HTTP proxy.

### 2. **`ce-with-public-slo-ip/`**
This folder contains the Terraform configuration for deploying **Customer Edge (CE)** with public IP addresses assigned to the **SLO network interfaces**. The IPs are managed either through new static IPs (google compute addess ) or existing IPs provided.
- **Use case**: Choose this configuration if you need public IPs directly assigned to the SLO network interfaces for external communication.
- **Key Features**:
  - Public IP assignment to SLO interfaces, either dynamically (new IPs) or statically (existing IPs).
  - Suitable for deployments requiring internet-facing interfaces with direct IP exposure. ( NO NAT )

### 3. **`ce-with-manual-xc-objects/` (Old Method)**
This folder contains the Terraform configuration for the **Customer Edge (CE)** with **manual XC objects** configuration. This method involves creating XC objects and tokens manually and managing them outside the Terraform configuration.
- **Use case**: Choose this configuration if you prefer or need to manage XC objects and tokens manually.
- **Key Features**:
  - Manual token and XC object management.
  - Suitable for more legacy deployments that rely on manually configured XC objects.

## How to Choose the Right Configuration

When selecting the configuration to use, consider your environment and specific requirements:

- **Use `ce-with-custom-proxy-nat/`**:
  - If you have a network proxy in place and need NAT functionality.
  - This is ideal for environments with strict security or internal routing policies that require proxy servers.

- **Use `ce-with-public-slo-ip/`**:
  - If you need public IP addresses for your SLO interfaces, either new or pre-existing.
  - This configuration is suitable for majority of the setups.

- **Use `ce-with-manual-xc-objects/` (Old Method)**:
  - If you prefer to manually manage XC objects and tokens.
  - This configuration is an old config which was created before SMSV2 Volterra resource was present. Can be used if you only want to automate cloud but want to stick with manual XC objects.


## Generic Structure of Each Folder

Each folder follows a consistent structure to ensure ease of use and maintainability. The main files in each folder are:

- **`main.tf`**: Contains the main Terraform configuration for resources such as Compute Engine instances, network interfaces, and site tokens.
- **`outputs.tf`**: Defines the output values, such as allocated public IPs, to be used for validation or further configuration.
- **`provider.tf`**: Specifies the providers for Google Cloud (GCP) and Volterra. This file is essential for connecting to the respective platforms.
- **`terraform.tfvars`**: Contains the user-specific values to customize the Terraform configuration, such as project ID, region, network settings, etc.
- **`variables.tf`**: Defines the input variables, ensuring flexibility in how the configuration is customized and applied.
- **`README.md`**: Describes the folder's purpose and gives deployment instructions.

## Deployment Guide

Each folder includes a **`README.md`** file with specific instructions on how to deploy the infrastructure:

Refer to the individual folder `README.md` files for more detailed steps and explanations based on the deployment method you choose.

## Conclusion

This repository offers flexible Terraform configurations to deploy high-availability Customer Edge (CE) clusters in Google Cloud, each designed for specific use cases, such as proxy setups, public IP assignments, and manual XC object management. Choose the configuration that best fits your environment and deploy your infrastructure with ease.

If you encounter any issues or need further assistance, feel free to consult the [documentation](https://docs.cloud.f5.com/docs-v2/multi-cloud-network-connect/how-to/site-management/deploy-sms-gcp-clickops) or reach out to the support team.


