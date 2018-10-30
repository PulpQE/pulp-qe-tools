#! /bin/bash
set -euo pipefail
#For example, let's say you have a virtual machines with hostname
#`r7.pulp.vm. Let's also say that you've configured passwordless SSH, and that
# the remote Ansible users have passwordless sudo access. You can install Pulp
# 2 on them with the following script:
source ./RHN_CREDENTIALS.sh
git clone https://github.com/pulp/pulp-ci/
pushd pulp-ci/ci/ansible
cat >inventory <<EOF
r7.pulp.vm
EOF
export PULP_VERSION=2.18
# Update the PULP_VERSION as necessary, or export an env variable.
echo "Starting Pulp 2 Installation."
ansible-playbook  -i inventory pulp_server.yaml \
    -e "pulp_version=${PULP_VERSION}" \
    -e "rhn_password=${RHN_PASSWORD}" \
    -e "rhn_pool=${RHN_POOL}" \
    -e "rhn_username=${RHN_USERNAME}"
echo "Cleaning."
popd
rm -r -f pulp-ci

