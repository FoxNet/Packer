source "googlecompute" "base" {
    account_file = "${var.gcp_account_file}"
    project_id = "${var.gcp_project_id}"
    ssh_username = "${local.gcp_ssh_username}"
    source_image_family = "${var.gcp_source_image}"
    preemptible = true
    zone = "${var.gcp_zone}"
    subnetwork = "${var.gcp_subnetwork}"
    image_name = "${var.prefix}-base-${var.gcp_source_image}-{{isotime \"2006-01-02-030405\"}}"
    image_family = "${var.prefix}-base"
    image_description = "${var.prefix} base image"
}

build {
    sources = [
        "source.googlecompute.base"
    ]
    provisioner "file" {
        source = "files/hashicorp"
        destination = "/tmp/"
    }
    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
        environment_vars = [
            "DOMAIN=${var.domain}",
            "CONSUL_ENCRYPTION_KEY=${var.consul_encryption_key}",
            "CONSUL_VERSION=${var.consul_version}",
            "CONSUL_TEMPLATE_VERSION=${var.consul_template_version}",
            "VAULT_VERSION=${var.vault_version}",
            "NOMAD_VERSION=${var.nomad_version}"
        ]
        script = "files/scripts/hashicorp.sh"
    }
}
