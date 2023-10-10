# TF GCP Compute Instance

A small, non-standard, Terraform module to deploy a single GCP Compute Instance
on a schedule for cost optimization.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- [google](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [google_compute_firewall.allow-ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_firewall.allow-ssh-from-specific-ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) (resource)
- [google_compute_instance.docker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) (resource)
- [google_compute_network.docker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) (resource)
- [google_compute_project_metadata.oslogin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata) (resource)
- [google_compute_project_metadata.security-key-enforcement](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata) (resource)
- [google_compute_subnetwork.docker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) (resource)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_credentials"></a> [credentials](#input\_credentials)

Description: GCP credentials

Type: `string`

Default: `"{}"`

### <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb)

Description: Storage size in gb

Type: `number`

Default: `100`

### <a name="input_image"></a> [image](#input\_image)

Description: The image to deploy to the machine

Type: `string`

Default: `"projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20210817"`

### <a name="input_labels"></a> [labels](#input\_labels)

Description: Map of labels to apply to the instance

Type: `map(string)`

Default: `{}`

### <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type)

Description: Type of compute instance to deploy

Type: `string`

Default: `"e2-standard-32"`

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the compute instance

Type: `string`

Default: `"docker-build"`

### <a name="input_network"></a> [network](#input\_network)

Description: Name of the network to be used

Type: `string`

Default: `"default"`

### <a name="input_project_id"></a> [project\_id](#input\_project\_id)

Description: The Google Cloud Project that the VM will run in.

Type: `string`

Default: `"wk-quality-assurance"`

### <a name="input_region"></a> [region](#input\_region)

Description: Region where resources are deployed to (e.g us-central1).

Type: `string`

Default: `"us-west1"`

### <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email)

Description: The service account email to use for the VM

Type: `string`

Default: `"your-service-account-email"`

### <a name="input_service_account_scopes"></a> [service\_account\_scopes](#input\_service\_account\_scopes)

Description: Scopes to apply to SA

Type: `list(string)`

Default: `[]`

### <a name="input_ssh_ranges"></a> [ssh\_ranges](#input\_ssh\_ranges)

Description: List of ip ranges to allow access to the instance

Type: `list(string)`

Default:

```json
[
  "10.0.0.1/32"
]
```

### <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork)

Description: Name of the subnetwork

Type: `string`

Default: `"default"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Tags to apply to the instance

Type: `list(string)`

Default: `[]`

### <a name="input_zone"></a> [zone](#input\_zone)

Description: The zone in which to deploy resources

Type: `string`

Default: `"us-central1-a"`

## Outputs

No outputs.
