# IBM Maximo Visual Inspection Edge v8.4.0 Terraform Template

IBM Maximo Visual Inspection makes computer vision with deep learning more accessible to business users. IBM Maximo Visual Inspection includes an intuitive toolset that empowers subject matter experts to label, train, and deploy deep learning vision models, without coding or deep learning expertise. It includes the most popular deep learning frameworks and their dependencies, and it is built for easy and rapid deployment and increased team productivity.

## License Agreement
By deploying this terraform template via IBM Cloud Schematics or via Terraform, you accept the Terms and Conditions of the [IBM 
International Program License Agreement](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?li_formnum=L-KBAI-C66PYB).  If you do not agree to these terms, do not deploy this template.

## Deployment Architecture

This provisions a dedicated instance of IBM Maximo Visual Inspection Edge in IBM Cloud utilizing IBM Cloud Schematics or with standalone Terraform.

Once created, its public IP address along with a username and password to log into the application will be displayed for easy access.

More specifically, it creates the following resources:

* a Virtual Machine on the Internet
* security group rules to allow HTTPS traffic

This instance is not backed up, and will expire 90 days from creation. Export any models or datasets before destroying it, and before it expires.

IMPORTANT: Back up any datasets or models prior to destruction of underlying VPC infrastructure.

IMPORTANT: You must also have access to the IBM Entitled Container Registry (i.e. you must be able to get an entitlement key from https://myibm.ibm.com/products-services/containerlibrary that allows access to the Maximo Application Suite).

NOTE: Please note that provisioning may take approximately ten minutes.


## Standalone Terraform Deployment Steps

### Prerequisites

To run as a standalone Terraform deployment, you need the following prerequisites.

```
terraform: 1.0 or greater
ibm terraform provider: v1.33 or greater
```

Use the [IBM Cloud VPC Terraform Documentation](https://cloud.ibm.com/docs/terraform?topic=terraform-getting-started#install) for information on how to install Terraform and the IBM Terraform Provider.

You also need to have an [IBM Cloud API Key](https://cloud.ibm.com/docs/iam?topic=iam-userapikey), and an [IBM Cloud Classic API Key](https://cloud.ibm.com/docs/iam?topic=iam-classic_keys).

### Installation Steps

1. Clone this git respository
2. Review the deployment attributes in the vm.tf file.  You may use the defaults.
3. Run `terraform apply`

When deployment starts, it will ask you for your API key.  The IBM Maximo Visual Inspection Trial will then take ~20 minutes to launch.

### Destroy

Simply run `terraform destroy` to remove the IBM Maximo Visual Inspection infrastructure.  The solution will also remove the VPC, Subnet, and all other associated resources it created.  It will not touch other infrastructure in your IBM Cloud account.


## Resources
* Learn more about IBM Maximo Visual Inspection at the [IBM Marketplace](https://www.ibm.com/us-en/marketplace/ibm-powerai-vision).
* Read product documentation in [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSRU69_1.3.0/).
* Engage with us on the [IBM Developer Forums](https://developer.ibm.com/answers/smart-spaces/361/powerai.html).
* Follow along the [IBM Maximo Visual Inspection Learning Path](https://developer.ibm.com/series/learning-path-powerai-vision/) to get started with Computer Vision applications, and deploy your first project built with IBM Maximo Visual Inspection today.
