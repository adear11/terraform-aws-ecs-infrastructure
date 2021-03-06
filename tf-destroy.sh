#!/usr/bin/env bash
echo "REPOSITORY: terraform-aws-ecs-infrastructure"
echo "SCRIPT: tf-destroy.sh <tfvars file>"
echo "EXECUTING: terraform destroy"

variablesFile="$1"
if [ -z "${variablesFile}" ]; then
    echo "Please specify a variables file in argument 1 for this script"
    exit
fi

if [ ! -e "${variablesFile}" ]; then
    echo "Could not locate variables file: ${variablesFile}"
    exit
fi

# Set name of remote terraform states bucket
env_name=$(sed -n 's/^env_name = "\(.*\)"$/\1/p' $variablesFile)
target_aws_region=$(sed -n 's/^region = "\(.*\)"$/\1/p' $variablesFile)

terraform_remote_states_bucket=terraform-states-${target_aws_region}

export AWS_DEFAULT_REGION=${target_aws_region}

# Uncomment if working locally and not via Jenkins
#export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
#export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)

# Uncomment for verbose terraform output
#export TF_LOG=info

# Remove the existing .terraform directory if it exists
rm -rf .terraform/ terraform.tfstate.backup

echo "Setting up terraform configuration for remote s3 state file storage"
echo "terraform init -backend-config \"bucket=${terraform_remote_states_bucket}\" -backend-config \"key=${env_name}/infrastructure.tfstate\" -backend-config \"region=${target_aws_region}\""
terraform init \
    -backend-config="bucket=${terraform_remote_states_bucket}" \
    -backend-config="key=${env_name}/infrastructure.tfstate" \
    -backend-config="region=${target_aws_region}"

echo "terraform destroy -force -var-file=\"${variablesFile}\""
if terraform destroy -force -var-file="${variablesFile}"; then
    echo "Terraform destroy succeeded."
else
    echo 'Error: terraform destroy failed.' >&2
    exit 1
fi

echo "done";