# IBM PowerAI Vision v1.1.5.1 Trial Edition

PowerAI Vision makes computer vision with deep learning more accessible to business users. PowerAI Vision includes an intuitive toolset that empowers subject matter experts to label, train, and deploy deep learning vision models, without coding or deep learning expertise. It includes the most popular deep learning frameworks and their dependencies, and it is built for easy and rapid deployment and increased team productivity.

## Deployment Architecture

This provisions a dedicated instance of PowerAI Vision Trial Edition in IBM Cloud utilizing IBM Cloud Schematics.

Once created, its public IP address along with a username and password to log into the application will be displayed for easy access.

More specifically, it creates the following resources:

* a Virtual Private Cloud (VPC)
* a Subnet
* a Virtual Server Instance within the VPC and a particular region and availability zone (AZ)
* a floating IP (FIP) address on the public Internet
* a security group that allows ingress traffic on port 443 (SSL) and on port 22 (for debug)

This instance is not backed up, and will expire 90 days from creation. Export any models or datasets before destroying it, and before it expires.

IMPORTANT: Reboots of the VM are not supported, and will result in loss of data. Back up any datasets or models prior to a reboot or shutdown of underlying VPC infrastructure.

NOTE: Please note that provisioning may take approximately fifteen minutes.

## Resources
* Learn more about IBM PowerAI Vision at the [IBM Marketplace](https://www.ibm.com/us-en/marketplace/ibm-powerai-vision).
* Read product documentation in [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSRU69_1.1.5/).
* Engage with us on the PowerAI [IBM Developer Forums](https://developer.ibm.com/answers/smart-spaces/361/powerai.html).
* Follow along the [IBM PowerAI Vision Learning Path](https://developer.ibm.com/series/learning-path-powerai-vision/) to get started with Computer Vision applications, and deploy your first project built with PowerAI Vision today.
