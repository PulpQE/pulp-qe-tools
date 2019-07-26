#! /bin/bash

# export PULP3_HOST=myhostname.com
# export PULP3_HOST_PORT=24817
# export PULP3_CONTENT_HOST=myhostname.com
# export PULP3_CONTENT_HOST_PORT=24816
# export PULP3_PLAYBOOK=source-install-plugins.yml
# curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash

# Optionally if you clone the qe-tools and want to use local playboks
# export PULP3_INSTALL_MODE=local
# export PULP3_HOST=myhostname.com
# export PULP3_PLAYBOOK=source-install-plugins.yml
# export PULP3_ROLES_PATH=/path/to/local/ansible-pulp (optional)
# ./install.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

HOST="${PULP3_HOST:-$(hostname)}"
HOST_PORT="${PULP3_HOST_PORT:-24817}"
echo "Installing on host: ${HOST}:${HOST_PORT} - set PULP3_HOST, PULP3_HOST_PORT env vars to override it"

CONTENT_HOST="${PULP3_CONTENT_HOST:-${PULP3_HOST}}"
CONTENT_HOST_PORT="${PULP3_CONTENT_HOST_PORT:-24816}"
echo "Content will be serving on ${CONTENT_HOST}:${CONTENT_HOST_PORT} - set PULP3_CONTENT_HOST, PULP3_CONTENT_HOST_PORT env vars to override it"

PLAYBOOK="${PULP3_PLAYBOOK:-install-pulp-from-source.yml}"
echo "Will use: ${PLAYBOOK} - set PULP3_PLAYBOOK env var to override it"

# wether we get the playbooks from qe-tools repo or use the local one
ANSIBLE_CONNECTION="${PULP3_ANSIBLE_CONNECTION:-ssh}"
echo "Will connect using ${ANSIBLE_CONNECTION} - set PULP3_ANSIBLE_CONNECTION=local|ssh env var to override it"

# wether we get the playbooks from qe-tools repo or use the local one
INSTALL_MODE="${PULP3_INSTALL_MODE:-github}"
echo "Will install from ${INSTALL_MODE} - set PULP3_INSTALL_MODE=local|github env var to override it"

# Where the roles are located? if empty will fetch from github
ROLES_PATH="${PULP3_ROLES_PATH:-github}"
echo "Will use ${ROLES_PATH} roles - set PULP3_ROLES_PATH=/path/to/ansible-pulp/ env var to override it"

PLUGINS="${PULP3_PLUGINS:-'pulp-file,pulp-rpm,pulp-docker,pulp-certguard,pulp-ansible'}"
echo "installing ${PLUGINS} - set PULP3_PLUGINS=pulp-file,pulp-docker to override it"

DEV_TOOLS="${PULP3_DEV_TOOLS:-off}"
echo "Dev Tools is ${DEV_TOOLS} - set PULP3_DEV_TOOLS=on"

QE_TOOLS_BRANCH="${PULP3_QE_TOOLS_BRANCH:-master}"
QE_TOOLS_USER="${PULP3_QE_TOOLS_USER:-PulpQE}"

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
  curl https://raw.githubusercontent.com/"${QE_TOOLS_USER}"/pulp-qe-tools/"${QE_TOOLS_BRANCH}"/pulp3/install_pulp3/ansible.cfg > ansible.cfg
  cat ansible.cfg
  curl https://raw.githubusercontent.com/"${QE_TOOLS_USER}"/pulp-qe-tools/"${QE_TOOLS_BRANCH}"/pulp3/install_pulp3/pcmd.sh > pcmd.sh
  cat pcmd.sh
  curl https://raw.githubusercontent.com/"${QE_TOOLS_USER}"/pulp-qe-tools/"${QE_TOOLS_BRANCH}"/pulp3/install_pulp3/"${PLAYBOOK}" > install.yml
  cat install.yml
else
  # For local debugging uncomment this line
  echo "Using local repo playbook"
  cp "$DIR"/ansible.cfg ansible.cfg
  cp "$DIR"/pcmd.sh pcmd.sh
  cp "$DIR"/"${PLAYBOOK}" install.yml
fi

chmod +x ./pcmd.sh

if [ "$ROLES_PATH" == "github" ]; then
    echo "Fetching ansible installer roles from github"
    git clone https://github.com/pulp/ansible-pulp.git
else
    echo "Using local roles from $ROLES_PATH"
    cp -R "$ROLES_PATH" ./ansible-pulp
fi

echo "Installing roles."
export ANSIBLE_ROLES_PATH="./ansible-pulp/roles/"
ansible-galaxy install -r ./ansible-pulp/requirements.yml --force
ansible-galaxy install pulp.pulp_rpm_prerequisites

echo "Available roles."
ansible-galaxy list

echo "Starting Pulp 3 Installation."
ansible-playbook -v -c "${ANSIBLE_CONNECTION}" -i "${HOST}", -u root install.yml \
  -e pulp_content_host="${CONTENT_HOST}":"${CONTENT_HOST_PORT}" \
  -e pulp_content_bind=0.0.0.0:"${CONTENT_HOST_PORT}" \
  -e pulp_api_port="${HOST_PORT}" \
  -e pulp_api_host="${CONTENT_HOST}":"${HOST_PORT}" \
  -e pulp_api_bind=0.0.0.0:"${HOST_PORT}" \
  -e plugins_list="${PLUGINS}" \
  -e install_dev_tools="${DEV_TOOLS}" \

echo "Cleaning."
popd

rm -r -f "${tempdir}"

sleep 4
echo "Is it working?"
curl -u admin:admin "${HOST}":"${HOST_PORT}"/pulp/api/v3/status/
