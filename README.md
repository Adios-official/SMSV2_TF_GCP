# F5 XC SMSV2 Customer Edge (CE) for GCP

🚀 This Terraform project deploys F5 Distributed Cloud (XC) SMSV2 (Secure Mesh Site V2) Customer Edge (CE) nodes on **Google Cloud Platform (GCP)**. This code is updated as per the latest release of Nov 16 2025.

This is a **unified and flexible** configuration. This module allows you to select your desired architecture by changing variables in the `terraform.tfvars` file.

This single codebase can handle:
* **"Cluster" Model**: A standard 1-node or 3-node Cluster site.
* **"vSite" Model**: Deploys 1, 2, or 3 independent nodes that are grouped into a single Virtual Site. This is the vsite based HA model.

Refer: [https://community.f5.com/kb/technicalarticles/f5-distributed-cloud-%E2%80%93-ce-high-availability-options-a-comparative-exploration/330189](https://community.f5.com/kb/technicalarticles/f5-distributed-cloud-%E2%80%93-ce-high-availability-options-a-comparative-exploration/330189)
* **Public IP**: Can create new Static IPs, use existing IPs, or assign no public IP at all.
* **NICs**: Supports both single-NIC (SLO only) and dual-NIC (SLO + SLI) deployments.

---

## Table of Contents
* [Core Configuration Concepts](#core-configuration-concepts)
    * [1. Deployment Model: Cluster vs. vSite](#1-deployment-model-cluster-vs-vsite)
    * [2. Networking: Public IP vs. NAT Gateway](#2-networking-public-ip-vs-nat-gateway)
    * [3. Node & NIC Count](#3-node--nic-count)
* [Prerequisites](#prerequisites)
* [File Structure](#file-structure)
* [How to Deploy](#how-to-deploy)
* [How to Destroy](#how-to-destroy)
* [Deployment Outputs](#deployment-outputs)
* [Troubleshooting & FAQ](#troubleshooting--faq)

---

## Core Configuration Concepts

You control the entire deployment architecture using the variables in `terraform.tfvars`.

### 1. Deployment Model: Cluster vs. vSite

The **`deployment_model`** variable is the most important choice. It determines the F5 XC site topology.

* **`"cluster"`: (Standard Cluster Model)**
    * Creates **one** `volterra_securemesh_site_v2` resource in F5 XC.
    * If `num_nodes = 1`, it will be a single node cluster.
    * If `num_nodes = 3`, it will be a 3 node cluster.
    * All nodes (1 or 3) use a single, shared registration token.
    * **Use this model** for standard single-node or 3-node Cluster sites.

* **`"vsite"`: (Virtual Site Model)**
    * Creates **one** `volterra_securemesh_site_v2` resource *per node*. (e.g., `num_nodes = 2` creates 2 separate site objects).
    * Creates a `volterra_virtual_site` resource that groups all the individual sites together using a shared label.
    * Each node gets its own unique registration token.
    * **Use this model** to deploy multiple, independent nodes but manage them as a single logical group in F5 XC as a Virtual Site.

### 2. Networking: Public IP vs. NAT Gateway

The **`ip_configuration.public_ip_assignment_type`** variable controls how external (public) IPs are (or are not) assigned to the SLO (eth0) interface.

* **`"CREATE_IP"`**: **(Default)**
    * Terraform will create a new **GCP Static External IP** for each node and assign it.
    * Use this for simple "greenfield" deployments where you want the nodes to be reachable from the internet (e.g., for Site-to-Site VPN).

* **`"EXISTING_IP"`**:
    * Terraform will use a list of existing IP addresses you provide in **`ip_configuration.existing_public_ips`**. The list count must match `num_nodes`.
    * Use this if you have already reserved specific Public IPs for this purpose.

* **`"NONE"`**: **(NAT / Proxy Model)**
    * No public IP will be assigned.
    * This is the correct choice for "brownfield" deployments where nodes are in a **private subnet** and egress traffic is handled by an existing **GCP NAT Gateway** or an HTTP proxy.
    * **If you select `NONE`, you must ensure your private subnet's route table has a route to the internet (e.g., `0.0.0.0/0` via a Cloud Router/NAT) so the node can register with F5 XC.**

### 3. Node & NIC Count

* **`num_nodes`**: The number of Compute Engine instances to deploy.
    * If `deployment_model = "cluster"`, must be **`1` or `3`**.
    * If `deployment_model = "vsite"`, can be **`1`, `2`, or `3`**.
* **`num_nics`**: The number of network interfaces per node.
    * **`1`**: Deploys only an SLO (eth0) interface.
    * **`2`**: Deploys both an SLO (eth0) and an SLI (eth1) interface.

---

## Prerequisites

1.  **Terraform** (v1.3.0 or newer).
2.  **GCP Account** with service account credentials configured for Terraform (e.g., via `gcloud auth application-default login`).
3.  **F5 Distributed Cloud Account** and an **API Credential (`.p12` file)**.
4.  **Custom F5 XC Image:** A custom F5 XC CE disk image must be imported into your GCP project (its path is specified by the `image` variable).

---

## File Structure

* `main.tf`: Contains the primary logic for creating all GCP (Compute, IPs, Networks, Firewalls) and F5 XC (site, token, label, vsite) resources.
* `variables.tf`: Defines all input variables, including their types, descriptions, and validation rules.
* `provider.tf`: Declares the `google` and `volterra` (F5 XC) providers.
* `terraform.tfvars`: A template for you to copy and fill in with your specific values.
* `outputs.tf`: Defines outputs, such as the public IPs of the created nodes.
* `README.md`: This file.

---

## How to Deploy

1.  **Clone this Repository**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-name>
    ```

2.  **Edit `terraform.tfvars`**
    This is the most important step. Fill in all the required values.

    * **XC Credentials:** `api_p12_file`, `api_url`
    * **Deployment Model:** `deployment_model`, `cluster_name`, `num_nodes`, `num_nics`
    * **GCP Compute:** `project_id`, `region`, `image`, `instance_type`, `ssh_public_key`
    * **GCP Networking:** `az_name`, `slo_subnetwork`, `sli_subnetwork` (if `num_nics = 2`)
    * **IP Configuration:** `ip_configuration`, `network_tier`
    * **Firewall Rules:** `create_firewall_rules`

    **Note:** The number of items in `az_name`, `slo_subnetwork`, and (if used) `sli_subnetwork` **must** match your `num_nodes` value.

3.  **Initialize Terraform**
    ```bash
    terraform init
    ```

4.  **Plan the Deployment**
    Review the changes Terraform will make.
    ```bash
    terraform plan
    ```

5.  **Apply the Configuration**
    Type `yes` to approve the deployment.
    ```bash
    terraform apply
    ```

---

## How to Destroy

To tear down all resources created by this project, run the destroy command.

```bash
terraform destroy
```
## Deployment Outputs

After a successful `terraform apply`, this module provides structured outputs for you to easily see what was created.

### 1. Deployment Summary

To see a complete summary of all the resources you deployed, run:

```bash
terraform output deployment_summary
```

This will display a structured object containing key information, such as:

* GCP Instance IDs and Zones
* Public and Private IP addresses
* Summary of Firewall Rule creation
* F5 XC Site Names
* The F5 XC Virtual Site Name (if created)
* A summary of your chosen inputs (like deployment_model, node_count, etc.)

## Troubleshooting & FAQ

## Troubleshooting & FAQ

**Q: `terraform plan` fails with a "Invalid value" error from a `check` block.**
* **A:** This is by design. We use `check` blocks to validate your variable combinations *before* creating resources. Read the error message carefully. It will tell you exactly what is wrong.
    * **Example 1:** `Invalid IP configuration: ... 'existing_public_ips' must contain exactly 3 IP(s).`
        * **Fix:** You set `num_nodes = 3` and `public_ip_assignment_type = "EXISTING_IP"`, but your `existing_public_ips` list does not contain 3 items. Add the correct number of IP strings.
    * **Example 2:** `Invalid node count: For 'cluster' model, num_nodes must be 1 or 3.`
        * **Fix:** You set `deployment_model = "cluster"` and `num_nodes = 2`. This is an invalid combination. Change `num_nodes` to `1` or `3`.

**Q: `terraform apply` fails with an error about `element()` or `count.index`.**
* **A:** This almost always means your lists in `terraform.tfvars` do not have the same number of items as `num_nodes`.
* **Fix:** Ensure that the number of items in `az_name`, `slo_subnetwork`, and (if used) `sli_subnetwork` *exactly* matches the value of `num_nodes`.

**Q: [GCP-SPECIFIC] Why does `terraform apply` fail with a "Bad Request" (400) error related to network tags?**
* **A:** GCP network tags are highly restrictive and are often the cause of API errors. They must be all **lowercase**, contain only alphanumeric characters or hyphens (`-`), and be between 1 and 63 characters long. Check the `tags` variable and the `cluster_name` to ensure compliance.

**Q: My Compute Engine instances were created, but the site never comes "Online" in the F5 XC Console.**
* **A:** This means the CE node cannot communicate with the F5 XC global network to register. This is an **egress connectivity problem** or a **firewall problem**.
* **Fix:**
    1.  **Check your egress path (NAT):** If `public_ip_assignment_type` is `"NONE"`, your private subnet (where the SLO NIC lives) **must** have an egress route to the internet (e.g., via a **GCP Cloud Router/NAT Gateway**).
    2.  **Check GCP Firewalls (Ingress/Egress):** If you set `create_firewall_rules = false` (bypassing Block 4), you must ensure your existing firewall rules allow:
        * **Outbound (Egress)** traffic to the internet (all ports/protocols for Control Plane).
        * **Inbound (Ingress)** traffic on TCP 443 and UDP 4500 from the F5 XC service ranges.
    3.  **Test Connectivity:** SSH into the Compute Engine instance using your `ssh_public_key`. Once inside, run `curl -v https://google.com`. If this fails or times out, your GCP networking (Routes, Firewalls, or NAT Gateway) is not configured correctly for egress.

**Q: `terraform plan` fails with an "Invalid cluster_name" error.**
* **A:** Your `cluster_name` does not meet the DNS-1035 label standard.
* **Fix:** The name must be all lowercase, can contain numbers and hyphens (`-`), must start with a letter, and must end with a letter or number.
    * **Good:** `my-f5-site-1`
    * **Bad:** `My-Site`, `1-site-f5`, `my-site-`
