#! /bin/bash

# export PULP3_HOST=myhostname.com
# export PULP3_PLAYBOOK=source-install-plugins.yml
# curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash

# Optionally if you clone the qe-tools and want to use local playboks
# export PULP3_INSTALL_MODE=local
# export PULP3_HOST=myhostname.com
# export PULP3_PLAYBOOK=source-install-plugins.yml
# export PULP3_ROLES_PATH=/path/to/local/ansible-pulp3 (optional)
# ./install.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

HOST="${PULP3_HOST:-$(hostname)}"
echo "Installing on host: ${HOST} - set PULP3_HOST env var to override it"

PLAYBOOK="${PULP3_PLAYBOOK:-source-install-plugins.yml}"
echo "Will use: ${PLAYBOOK} - set PULP3_PLAYBOOK env var to override it"

# wether we get the playbooks from qe-tools repo or use the local one
INSTALL_MODE="${PULP3_INSTALL_MODE:-github}"
echo "Will install from ${INSTALL_MODE} - set PULP3_INSTALL_MODE=local|github env var to override it"

# Where the roles are located? if empty will fetch from github
ROLES_PATH="${PULP3_ROLES_PATH:-github}"
echo "Will use ${ROLES_PATH} roles - set PULP3_ROLES_PATH=/path/to/ansible-pulp3/ env var to override it"

# requirements
if ! git --version > /dev/null; then
  echo 'git is required'
  exit 1
fi

if ! sed --version > /dev/null; then
  echo 'sed is required'
  exit 1
fi

if ! python3 -V > /dev/null; then
  echo 'python3 is required'
  exit 1
fi

if ! ansible-playbook --version > /dev/null; then
  echo 'Ansible Playbook is required is required'
  exit 1
fi

if ! ansible-galaxy --version > /dev/null; then
  echo 'Ansible Galaxy is required is required'
  exit 1
fi

# make a temp dir to clone all the things
tempdir="$(mktemp --directory)"
pushd "${tempdir}"

if [ "$INSTALL_MODE" == "github" ]; then
  # get the playbook locally
  echo "Fetching playbook from github"
  curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/ansible.cfg > ansible.cfg
  curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/"${PLAYBOOK}" > install.yml
else
  # For local debugging uncomment this line
  echo "Using local repo playbook"
  cp "$DIR"/ansible.cfg ansible.cfg
  cp "$DIR"/"${PLAYBOOK}" install.yml
fi

if [ "$ROLES_PATH" == "github" ]; then
    echo "Fetching ansible installer roles from github"
    git clone https://github.com/pulp/ansible-pulp3.git
else
    echo "Using local roles from $ROLES_PATH"
    cp -R "$ROLES_PATH" ./ansible-pulp3
fi

echo "Installing roles."
export ANSIBLE_ROLES_PATH="./ansible-pulp3/roles/"
ansible-galaxy install -r ./ansible-pulp3/requirements.yml --force

echo "Available roles."
ansible-galaxy list

echo "Starting Pulp 3 Installation."
ansible-playbook -v -i "${HOST}", -u root install.yml -e pulp_content_host="${HOST}:8080"

echo "Cleaning."
popd

rm -r -f "${tempdir}"

echo "Is it working?"
curl -u admin:admin "${HOST}":80/pulp/api/v3/status/
