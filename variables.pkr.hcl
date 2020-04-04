variable "prefix" {}
variable "domain" {}

variable "gcp_project_id" {}
variable "gcp_account_file" {}
variable "gcp_source_image" {
    default = "debian-10"
}
variable "gcp_image_users" {
    default = {
        "debian-9"  = "debian"
        "debian-10" = "debian"
    }
}
variable "gcp_zone" {}
variable "gcp_subnetwork" {}

variable "consul_version" {
    default = "1.7.2"
}
variable "consul_template_version" {
    default = "0.24.1"
}
variable "vault_version" {
    default = "1.3.4"
}
variable "nomad_version" {
    default = "0.10.5"
}

locals {
    gcp_ssh_username = "${lookup(var.gcp_image_users, var.gcp_source_image, "root")}"
}

