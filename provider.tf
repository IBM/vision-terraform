variable "ibmcloud_api_key" {
    description = "Denotes the IBM Cloud API key to use "
}



#################################################
##               End of variables              ##
#################################################

provider "ibm" {
    version          = ">= 0.20"
    ibmcloud_api_key = "${var.ibmcloud_api_key}"
    generation       = "2"
    region           = "${var.vpc_region}" //this will eventually need to be a selection by the user
}
