# IBM Visual Insights v1.2.0.0 Trial Edition Terraform Template

IBM Visual Insights makes computer vision with deep learning more accessible to business users. IBM Visual Insights includes an intuitive toolset that empowers subject matter experts to label, train, and deploy deep learning vision models, without coding or deep learning expertise. It includes the most popular deep learning frameworks and their dependencies, and it is built for easy and rapid deployment and increased team productivity.

## License Agreement
By deploying this terraform template via IBM Cloud Schematics or via Terraform, you accept the Terms and Conditions of the [IBM License Agreement for Evaluation of Programs](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?li_formnum=L-CKIE-BL45W3).  If you do not agree to these terms, do not deploy this template.

## Deployment Architecture

This provisions a dedicated instance of IBM Visual Insights Trial Edition in IBM Cloud utilizing IBM Cloud Schematics or with standalone Terraform.

Once created, its public IP address along with a username and password to log into the application will be displayed for easy access.

More specifically, it creates the following resources:

* a Virtual Private Cloud (VPC)
* a Subnet
* a Virtual Server Instance within the VPC and a particular region and availability zone (AZ)
* a floating IP (FIP) address on the public Internet
* a security group that allows ingress traffic on port 443 (SSL) and on port 22 (for debug)

This instance is not backed up, and will expire 90 days from creation. Export any models or datasets before destroying it, and before it expires.

IMPORTANT: Reboots of the VM are not supported, and will result in loss of data. Back up any datasets or models prior to a reboot or shutdown of underlying VPC infrastructure.

NOTE: Please note that provisioning may take approximately twenty minutes.


## Standalone Terraform Deployment Steps

### Prerequisites

To run as a standalone Terraform deployment, you need the following prerequisites.

```
terraform: v0.11.x or greater
ibm terraform provider: v0.24.x or greater
```

Use the [IBM Cloud VPC Terraform Documentation](https://cloud.ibm.com/docs/terraform?topic=terraform-getting-started#install) for information on how to install Terraform and the IBM Terraform Provider.

You also need to have an [IBM Cloud API Key](https://cloud.ibm.com/docs/iam?topic=iam-userapikey).

### Installation Steps

1. Clone this git respository
2. Review the deployment attributes in the vm.tf file.  You may use the defaults.
3. Run `terraform apply`

When deployment starts, it will ask you for your API key.  The IBM Visual Insights Trial will then take ~20 minutes to launch.

### Destroy

Simply run `terraform destroy` to remove the IBM Visual Insights infrastructure.  The solution will also remove the VPC, Subnet, and all other associated resources it created.  It will not touch other infrastructure in your IBM Cloud account.


## Resources
* Learn more about IBM Visual Insights at the [IBM Marketplace](https://www.ibm.com/us-en/marketplace/ibm-powerai-vision).
* Read product documentation in [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSRU69_1.2.0/).
* Engage with us on the [IBM Developer Forums](https://developer.ibm.com/answers/smart-spaces/361/powerai.html).
* Follow along the [IBM Visual Insights Learning Path](https://developer.ibm.com/series/learning-path-powerai-vision/) to get started with Computer Vision applications, and deploy your first project built with IBM Visual Insights today.
