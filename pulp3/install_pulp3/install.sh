#! /bin/bash

# export PULP3_HOST=myhostname.com
# export PULP3_PLAYBOOK=source-install-plugins.yml
# curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash

HOST="${PULP3_HOST:-$(hostname)}"
echo "Installing on host: ${HOST} - set PULP3_HOST env var to override it"

PLAYBOOK="${PULP3_PLAYBOOK:-source-install.yml}"
echo "Will use: ${PLAYBOOK} - set PULP3_PLAYBOOK env var to override it"

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

git clone https://github.com/pulp/ansible-pulp3.git

# pip should be updated
# FIXME: installer should take care of it.
sed -i -e "s/- name: Install pulpcore package from source/- name: Upgrade pip\n      pip:\n        name: pip\n        state: latest\n        virtualenv_command: '{{ pulp_python_interpreter }} -m venv'\n        virtualenv: '{{pulp_install_dir}}'\n\n    - name: Install pulpcore package from source/g" ./ansible-pulp3/roles/pulp3/tasks/install.yml

# get the playbook locally
curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/ansible.cfg > ansible.cfg
curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/"${PLAYBOOK}" > install.yml

# For local debugging uncomment this line
# cp ~/Projects/pulp/pulp-qe-tools/pulp3/install_pulp3/"${PLAYBOOK}" install.yml

echo "Installing roles."
export ANSIBLE_ROLES_PATH="./ansible-pulp3/roles/"
ansible-galaxy install -r ./ansible-pulp3/requirements.yml

echo "Available roles."
ansible-galaxy list

echo "Starting Pulp 3 Installation."
ansible-playbook -v -i "${HOST}", -u root install.yml 

echo "Cleaning."
popd

rm -r -f "${tempdir}"

echo "Is it working?"
curl -u admin:admin "${HOST}":80/pulp/api/v3/status/
