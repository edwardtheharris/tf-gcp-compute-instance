---
abstract: >
   This is some Terraform code that will deploy to a GCP account one Google
   compute instance with enough resources to run Docker for development or a
   Minikube cluster for Kubernetes.
authors: Xander Harris
date: 2024-01-30
title: TF GCP Compute Instance
---

A small, non-standard, Terraform module to deploy a single GCP Compute Instance
on a schedule for cost optimization.

You will need an active Google Cloud Project account for this to work, it will
also require an associated Billing Account with a valid method of payment.

## Installation

To run this effectively on a Mac (which is at present the only supported
platform), you will need to do the following.

> This process assumes you are using [homebrew](https://brew.sh).

1. Install terraform and related utilities.

   ```sh
   # These are required
   brew install terraform terraform-docs
   # These are optional
   brew install terraform-graph-beautifier terraform-inventory terraform-lsp
   ```

2. Install the Google Cloud SDK

   ```sh
   brew install google-cloud-sdk
   ```

## Cost

The cost of running this resource is roughly 0.6 USD per day so long as you
destroy the resources when you are finished working and leave the spot instance
setting set to yes.

This was developed as a solution to the problem of running a thick stack in
Docker on a workstation that just couldn't hack it. However, in defense of the
workstation in question, the stack it was being asked to run would be taxing
on even the most powerful desktop systems. That said, this solution works
very well in that it is very affordable (~9 USD/mo, depending on how use it's
getting), efficient, simple, repeatable, reliable, and secure.

The author has been using this daily since major work on it was
completed with the
[v0.0.2](https://github.com/edwardtheharris/tf-gcp-compute-instance/releases/tag/v0.0.2)
release.

## Secret values

You may wish to the contents of some of the variables listed below, to do this
you will need to do two things. The first is to create a directory
named `secrets` in this repository and use that to store your SSH/GPG keys
locally, then create a tfvars file with the name `secret.auto.tfvars`.

Any directories or filenames with a name that contains the word `secret` are
ignored by git and so are safe to store locally.

<!-- BEGIN_TF_DOCS -->
## Usage

This module uses only standard resources, so usage is standard as well.

## Providers

| Name | Version |
|------|---------|
| google | 5.14.0 |

## Outputs

| Name | Description |
|------|-------------|
| dns\_name | Output the DNS name |
| instance\_public\_ip | Output the public IP address of the Docker instance |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| disk\_size\_gb | Storage size in GB | `number` | `100` | no |
| gcp-creds | Path to a file containing GCP service account credentials in JSON format. | `string` | `"secrets/gcp.json"` | no |
| image | The image to deploy to the machine | `string` | `"projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20210817"` | no |
| local\_keys | SSH keys to be used across the daily deployment of instances | `map(string)` | `{}` | no |
| machine\_type | Type of compute instance to deploy | `string` | `"n2-standard-2"` | no |
| name | Name of the compute instance | `string` | `"docker-build"` | no |
| network | Name of the network to be used | `string` | `"default"` | no |
| project\_id | The Google Cloud Project that the VM will run in. | `string` | `"remote-docker-development"` | no |
| region | Region where resources are deployed to (e.g us-central1). | `string` | `"us-west1"` | no |
| service\_account\_email | The service account email to use for the VM | `string` | `"your-service-account-email"` | no |
| service\_account\_scopes | Scopes to apply to SA | `list(string)` | `[]` | no |
| ssh\_public\_key | Publish ssh key with which to login to the instance | `string` | `""` | no |
| ssh\_ranges | List of IP ranges to allow access to the instance | `list(string)` | ```[ "10.0.0.1/32" ]``` | no |
| subnetwork | Name of the subnetwork | `string` | `"default"` | no |
| tags | Tags to apply to the instance | `list(string)` | `[]` | no |
| zone | The zone in which to deploy resources | `string` | `"us-central1-a"` | no |

## Resources

- resource.google_compute_firewall.allow-all-tcp-from-local (main.tf#146)
- resource.google_compute_instance.docker (main.tf#67)
- resource.google_compute_resource_policy.weekly (main.tf#25)
- data source.google_compute_address.remote-development-docker (network.tf#12)
- data source.google_compute_network.docker (network.tf#2)
- data source.google_compute_subnetwork.docker (network.tf#7)
- data source.google_dns_managed_zone.rdd (dns.tf#36)
- data source.google_dns_record_set.rdd (dns.tf#15)

## Links

- [license](license.md)
<!-- END_TF_DOCS -->

### Connecting

To connect to the instance you may run a command similar to the one below.

```shell
gcloud compute ssh --zone "us-west1-c" "docker-build" --project "remote-development-docker"
```

However, if everything went as expected you should be able to run this instead.

```shell
ssh your.instance.tld
```

You should find a running Ubuntu system with the same username as your local.
It should be running Docker and Minikube. Also, Skaffold
and Helm should be installed and ready to use.
