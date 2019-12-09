variable "ibmcloud_api_key" {
    description = "Denotes the IBM Cloud API key to use "
}



/**
//default is us-south, so no need for this - but will eventually change this
variable "ibmcloud_region" {
    description = "Denotes which IBM Cloud region to connect to"
    default     = "us-south"
}
*/

/**
//we will add this back when there's multiple zones
variable "ibmcloud_zone" {
    description = "Denotes which zone within the IBM Cloud region to create the VM in"
    default     = "us-south-3"
}
*/

#################################################
##               End of variables              ##
#################################################

provider "ibm" {
    version          = ">= 0.17.6"
    ibmcloud_api_key = "${var.ibmcloud_api_key}"
    generation       = "2"
    region           = "us-south" //this will eventually need to be a selection by the user
}
