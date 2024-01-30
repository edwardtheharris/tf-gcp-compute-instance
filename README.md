---
abstract: This is some Terraform code that will deploy to a GCP account one Google compute instance with enough resources to run Docker for development, or a minikube cluster for Kubernetes.
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
Docker on a workstation that just couldn't hack it. Though, in defense of the
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
you will need to do two things. The first is create a directory `secrets`
in this repository and use that to store your ssh/gpg keys locally, then
create a tfvars file with the name `secret.auto.tfvars`.

Any directories or filenames with `secret` in the name are ignored by git
and so safe to store locally.

<!-- BEGIN_TF_DOCS -->
## Usage

This module uses only standard resources, so usage is standard as well.

## Providers

The following providers are used by this module:

- google (5.14.0)

## Outputs

The following outputs are exported:

### dns\_name

Description: Output the DNS name

### instance\_public\_ip

Description: Output the public IP address of the Docker instance

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### disk\_size\_gb

Description: Storage size in GB

Type: `number`

Default: `100`

### gcp-creds

Description: Path to a file containing GCP service account credentials in JSON format.

Type: `string`

Default: `"secrets/gcp.json"`

### image

Description: The image to deploy to the machine

Type: `string`

Default: `"projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20210817"`

### local\_keys

Description: SSH keys to be used across the daily deployment of instances

Type: `map(string)`

Default: `{}`

### machine\_type

Description: Type of compute instance to deploy

Type: `string`

Default: `"n2-standard-2"`

### name

Description: Name of the compute instance

Type: `string`

Default: `"docker-build"`

### network

Description: Name of the network to be used

Type: `string`

Default: `"default"`

### project\_id

Description: The Google Cloud Project that the VM will run in.

Type: `string`

Default: `"remote-docker-development"`

### region

Description: Region where resources are deployed to (e.g us-central1).

Type: `string`

Default: `"us-west1"`

### service\_account\_email

Description: The service account email to use for the VM

Type: `string`

Default: `"your-service-account-email"`

### service\_account\_scopes

Description: Scopes to apply to SA

Type: `list(string)`

Default: `[]`

### ssh\_public\_key

Description: Publish ssh key with which to login to the instance

Type: `string`

Default: `""`

### ssh\_ranges

Description: List of IP ranges to allow access to the instance

Type: `list(string)`

Default:

```json
[
  "10.0.0.1/32"
]
```

### subnetwork

Description: Name of the subnetwork

Type: `string`

Default: `"default"`

### tags

Description: Tags to apply to the instance

Type: `list(string)`

Default: `[]`

### zone

Description: The zone in which to deploy resources

Type: `string`

Default: `"us-central1-a"`

## Resources

- resource.google_compute_firewall.allow-all-tcp-from-local (main.tf#122)
- resource.google_compute_instance.docker (main.tf#74)
- resource.google_compute_resource_policy.weekly (main.tf#32)
- resource.google_dns_managed_zone.rdd (dns.tf#26)
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

### Post-apply Steps

Local provisioners are discouraged in the TF docs, so this command will need
to be run manually on your local machine after the apply has been completed.

```hcl
provisioner "local-exec" {
   command     = "source _scripts/wait-for-ssh.sh ${google_compute_instance.docker.network_interface[0].access_config[0].nat_ip} ${var.local_keys.private} ${var.local_keys.public} ${var.local_keys.user}"
   interpreter = ["/bin/bash", "-c"]
   working_dir = path.module
}
```

Here is an example of how to use the command. It will also output usage
information if you forget to set one of the variables.

```shell
remote=your.remote.host
private_key=$(cat secrets/id_rsa| base64)
public_key=$(cat secrets/id_rsa.pub| base64)

source _scripts/wait-for-ssh.sh $remote $private_key $public_key $USER
```

> Note the public and private keys are expected to be base64 encoded.

### [direnv](https://direnv.net)

If you've got [direnv](https://direnv.net) installed and configured, you could
have the following files in your (uncommitted, obviously) secrets directory.

```shell
secrets
├── id_rsa
├── id_rsa.pub
└── private-key.gpg
```

And that would allow you to use an `.envrc` file very similar to the one
below in order to complete the deployment of your compute instance.

> `.envrc`

```shell
#!/bin/bash

gpg_key=secrets/private-key.gpg
private_key=$(base64<secrets/id_rsa)
public_key=$(base64<secrets/id_rsa.pub)
remote=your-remote.great-googly-moogly.com

export gpg_key
export private_key
export public_key
export remote

# source _scripts/wait-for-ssh.sh $remote $private_key $public_key $USER $gpg_key
```

Because the source command at the end must be executed after the Compute
Instance has completed its deployment it's left as a comment to be copy/pasted
into your terminal once the Terraform deployment is done.
