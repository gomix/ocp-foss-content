#!/usr/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")" 
source "$SCRIPT_DIR/config.env"

# configure aws credentials
## for cli
sed -i "s|aws_secret_access_key[[:space:]]*=.*|aws_secret_access_key = $AWS_SECRET_ACCESS_KEY|" ~/.aws/credentials

sed -i "s|aws_access_key_id[[:space:]]*=.*|aws_access_key_id = $AWS_ACCESS_KEY_ID|" ~/.aws/credentials

## for ansible
sed -i "s|aws_secret_key:.*|aws_secret_key: $AWS_SECRET_ACCESS_KEY|" /home/ggomezsa/Git/ocp-foss-content/demos/ocp-on-aws/compact/ipi/ansible/vars/aws.yaml

sed -i "s|aws_access_key:.*|aws_access_key: $AWS_ACCESS_KEY_ID|" /home/ggomezsa/Git/ocp-foss-content/demos/ocp-on-aws/compact/ipi/ansible/vars/aws.yaml

# TODO:
# 1. Add vars for install-config.yaml
#    aws_region: eu-central-1
#    defaultMachinePlaftorm_type: c5a.4xlarge
# 2. Inject pullSecret
# 3. Inject sshKey
#
# Generate new install-config.yaml
# compact
envsubst < bu/install-config.yaml.compact-template > install-config.yaml

echo "Done"

