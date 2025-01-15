# Project Folder Structure for SMSV2 on GCP with Terraform

This repository follows a specific folder naming structure to organize various configurations for different setups of SMSV2 on Google Cloud Platform (GCP) with Terraform. Below is an explanation of the naming conventions and guidelines for users to understand the structure and its usage.

## Folder Naming Structure

The naming structure is designed to clearly represent the configuration setup for each environment, such as the number of nodes, network configuration, and specific Terraform modules being used. The format follows:

<node-count> NODE - <nic-count> NIC - SMSV2 - GCP - CE - <configuration-details>


Where:
- `<node-count>`: The number of nodes (either 1 or 3 nodes) involved in the setup.
- `<nic-count>`: The number of NICs (Network Interface Cards), which could be 1 or 2.
- `SMSV2`: Denotes the SMSV2 configuration being used.
- `GCP`: Indicates that the setup is on Google Cloud Platform (GCP).
- `CE`: Represents the Cloud Engine or the underlying environment.
- `<configuration-details>`: Additional configuration details specifying network setups such as NAT, public IP, or proxy.

### Example Breakdown:

#### `3 NODE - 1 NIC - SMSV2 - GCP - CE - WITH NAT`

- **3 NODE**: Refers to a setup with 3 nodes.
- **1 NIC**: Indicates that there is 1 Network Interface Card (NIC) attached to each node.
- **WITH NAT**: Denotes that the nodes are configured with Network Address Translation (NAT) for internet access.

#### Other Examples:

- `3 NODE - 2 NIC - SMSV2 - GCP - CE - WITH NAT & PROXY`: Refers to a setup with 3 nodes, 2 NICs, NAT enabled, and a proxy configured.
- `1 NODE - 1 NIC - SMSV2 - GCP - CE - STATIC PUBLIC IP & W/O NAT`: Represents a single node with 1 NIC, a static public IP, and no NAT configured.

## Folder Details

Each folder contains configurations for specific environments based on the node and NIC setup. The folders are organized as follows:

- **3N-1NIC-NAT**: Configurations for a 3-node setup with 1 NIC and NAT enabled.
- **3N-1NIC-DYN**: Configurations for a 3-node setup with 1 NIC and dynamic/Automatically alloted public IP, without NAT.
- **3N-1NIC-NAT-PROXY**: Configurations for a 3-node setup with 1 NIC, NAT, and a proxy.
- **3N-1NIC-STATIC**: Configurations for a 3-node setup with 1 NIC and static public IP, without NAT.
- **3N-2NIC-NAT**: Configurations for a 3-node setup with 2 NICs and NAT enabled.
- **3N-2NIC-DYN**: Configurations for a 3-node setup with 2 NICs and dynamic/Automatically alloted  public IP, without NAT.
- **3N-2NIC-NAT-PROXY**: Configurations for a 3-node setup with 2 NICs, NAT, and a proxy.
- **3N-2NIC-STATIC**: Configurations for a 3-node setup with 2 NICs and static public IP, without NAT.
- **1N-1NIC-NAT**: Configurations for a single node setup with 1 NIC and NAT enabled.
- **1N-1NIC-DYN**: Configurations for a single node setup with 1 NIC and dynamic/Automatically alloted  public IP, without NAT.
- **1N-1NIC-NAT-PROXY**: Configurations for a single node setup with 1 NIC, NAT, and a proxy.
- **1N-1NIC-STATIC**: Configurations for a single node setup with 1 NIC and static public IP, without NAT.
- **1N-2NIC-NAT**: Configurations for a single node setup with 2 NICs and NAT enabled.
- **1N-2NIC-DYN**: Configurations for a single node setup with 2 NICs and dynamic/Automatically alloted  public IP, without NAT.
- **1N-2NIC-NAT-PROXY**: Configurations for a single node setup with 2 NICs, NAT, and a proxy.
- **1N-2NIC-STATIC**: Configurations for a single node setup with 2 NICs and static public IP, without NAT.


## How to Use

### Setting Up on Google Cloud Platform (GCP)

1. **Prerequisites**: Ensure you have access to a GCP account and have the [Google Cloud SDK](https://cloud.google.com/sdk) installed on your local machine.
   
2. **Terraform Setup**: This repository contains Terraform configurations to set up the described environments. You need to install [Terraform](https://www.terraform.io/downloads.html) to run the scripts.

3. **Environment Configuration**:
   - Navigate to the folder corresponding to the configuration you want to deploy (e.g., `3 NODE - 1 NIC - SMSV2 - GCP - CE - WITH NAT`).
   - Ensure your Terraform configuration matches your GCP environment (e.g., project ID, region).
   - Ensure that you have valid API Certificate from Distributed cloud and the passowrd.
   - Download the configuration files in folder of your choice
   - Edit terraform.tfvars to suite your configuration and environment 

4. **Run Terraform**:
   - Initialize the Terraform working directory:
     ```bash
     terraform init
     ```
   - Apply the configuration:
     ```bash
     terraform apply
     ```

5. **Monitor and Modify**:
   - After running `terraform apply`, Terraform will create the required infrastructure. You can monitor the setup and modify configurations as needed.

### Folder-Specific Considerations

- **With NAT**: If the folder has `WITH NAT` in its name, the nodes are configured to route traffic through a NAT gateway ( already existing in customer architecture ) to access external resources. No Public IP is alloted to the nodes here.
- **Static or Dynamic Public IP**: Folders with `STATIC PUBLIC IP` use a static IP for external connectivity, while `DYNAMIC PUBLIC IP` uses an IP that is alloted automatically by GCP.
- **Proxy Configurations**: Folders with `PROXY` assumes a proxy setup for routing traffic between the internal network and external resources.  

