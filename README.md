# Using Terraform for Kubernetes Clusters

This example demonstrates how to use Terraform to create Kubernetes clusters and
deploy applications onto them using Helm charts.

It uses Terraform Cloud pipelines to separate cluster configuration and
application deployment.

* Cluster Deployment - under `/cluster`
* Consul Deployment - deploys Consul to Kubernetes cluster. Under `/consul`.
* Vault Deployment - deploys Vault to connect with Consul backend. Under
  `/vault`.

# Step 1: Deploy a Kubernetes Cluster

You'll need to specify the following variables (in `variables.tf`) and load them
into Terraform Cloud.

In addition to the variables, you'll need to specify the following __sensitive
environment variables__:

1. `GOOGLE_CREDENTIALS`: JSON of GCP credentials. Must have access to GKE admin.
   You must flatten the JSON (remove newlines) before pasting it into Terraform
   Cloud. Run `cat <key file>.json | jq -c`.

The pipeline will output the Kubernetes credentials for consumption by the Helm
charts.

# Step 2: Deploy Consul backend for Vault

In Terraform Cloud, you'll need to specify a __Run Trigger__ that uses the
Kubernetes cluster deployment's workspace. The Consul backend deployment will
exist in a different workspace entirely in order to separate cluster
configuration from Consul deployment.

Include __VCS Integration__ with the working directory to `consul`. Make sure
you select __Include submodules on clone__ under the workspace's VCS settings.
We don't have a Helm chart repository so its reference exists as a submodule.

Specify variables in `variables.tf` within the Terraform Cloud workspace for the
Consul deployment.

# Step 3: Deploy Vault

In Terraform Cloud, you'll need to specify a __Run Trigger__ that uses the
Consul deployment's workspace. This is because this Vault configuration needs to
use a Consul backend.

Include __VCS Integration__ with the working directory to `vault`. Make sure you
select __Include submodules on clone__ under the workspace's VCS settings. We
don't have a Helm chart repository so its reference exists as a submodule.

Specify variables in `variables.tf` within the Terraform Cloud workspace for the
Vault deployment.

# Step 4: Update Cluster

Update the toggle in the cluster to expand it to multiple nodes. In the
**cluster** pipeline, set the `enable_consul_and_vault` variable to `true`.
This scales the cluster to 3 nodes and triggers the Consul and Vault pipelines
to deploy Consul and Vault.

If you set `enable_consul_and_vault` to `false`, it scales down the cluster to 1
node and deletes the Consul and Vault deployment.