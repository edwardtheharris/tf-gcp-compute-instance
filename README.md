# TF GCP Compute Instance

A small, non-standard, Terraform module to deploy a single GCP Compute Instance
on a schedule for cost optimization.

You will need an active Google Cloud Project account for this to work, it will
also require an associated Billing Account with a valid method of payment.

The cost of running this resource is roughly 0.9 USD per day so long as you
destroy the resources when you are finished working and leave the spot instance
setting set to yes.

<!-- BEGIN_TF_DOCS -->
## Usage

This module uses only standard resources, so usage is standard as well.

## Providers

| Name | Version |
|------|---------|
| google | 5.1.0 |

## Outputs

| Name | Description |
|------|-------------|
| dns\_name | Output the DNS name |
| instance\_public\_ip | Output the public IP address of the Docker instance |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| disk\_size\_gb | Storage size in GB | `number` | `100` | no |
| gcp-creds | Path to a file containing GCP credentials | `string` | `"{}"` | no |
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

- resource.google_compute_firewall.allow-all-tcp-from-local (main.tf#108)
- resource.google_compute_instance.docker (main.tf#41)
- resource.google_compute_resource_policy.weekly (main.tf#24)
- data source.google_compute_address.remote-development-docker (network.tf#12)
- data source.google_compute_network.docker (network.tf#2)
- data source.google_compute_subnetwork.docker (network.tf#7)
- data source.google_dns_managed_zone.rdd (dns.tf#36)
- data source.google_dns_record_set.rdd (dns.tf#15)

## Links

- [license](license.md)
<!-- END_TF_DOCS -->

## Connecting

To connect to the instance you should run a command similar to the one below.

```shell
gcloud compute ssh --zone "us-west1-c" "docker-build" --project "remote-development-docker"
```
