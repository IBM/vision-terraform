variable "ibmcloud_api_key" {
    description = "Enter your IBM Cloud API Key. To get this key, go to https://cloud.ibm.com/iam/apikeys and generate a new 'IBM Cloud API Key'"
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
