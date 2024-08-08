provider "aws" {
  region = var.region
}

locals {
  fqdn = "${var.artifact}.${var.env}.${var.tldp1}"
}

resource "aws_s3_bucket" "files" {
  bucket = local.fqdn
}