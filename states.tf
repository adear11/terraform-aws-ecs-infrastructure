# Jenkins Terraform Goodness :)
# @author Joshua Copeland <JoshuaRCopeland@gmail.com>


# Keeping your terraform.state files locally or commited in version control is generally a bad idea.
# Hence why we are telling terraform to use "s3" as our "backend" to put state files into
terraform {
  backend "s3" {
  }
}

# This tells terraform we will use AWS. Your key/secret is being set via env vars to magically get set into this node.
provider "terraform" {
  version = "~> 0.1"
}
provider "template" {
  version = "~> 0.1"
}
provider "aws" {
  version = "~> 0.1"
  region = "${var.region}"
}

# Where to store the terraform state file. Note that you won't have a local tfstate file, because its stored remotly.
data "terraform_remote_state" "infrastructure_state" {
  backend = "s3"
  config {
    bucket = "terraform-states-${var.region}"
    key = "${var.env_name}/infrastructure.tfstate"
    region = "${var.region}"
  }
}
