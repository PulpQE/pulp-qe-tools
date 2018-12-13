#! /bin/bash

# export PULP3_HOST=myhostname.com
# curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash

set -euo pipefail

# Shows the hostname where to install or fail
echo "${PULP3_HOST}"

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

# apply fix to editable mode
sed -i -e 's/editable: yes/editable: no/g' ./ansible-pulp3/roles/pulp3/tasks/install.yml
sed -i -e 's/editable:yes/editable: no/g' ./ansible-pulp3/roles/pulp3/tasks/install.yml

# apply fix required to install pulp_rpm on fedora
sed -i -e "s/- name: Install pulpcore package from source/- name: pulp rpm\n      pip:\n        name: scikit-build\n        virtualenv: '{{pulp_install_dir}}'\n\n    - name: Install pulpcore package from source/g" ./ansible-pulp3/roles/pulp3/tasks/install.yml

# echo "
#     - name: Install pulp_rpm extra packages
#       pip: 
#         name= '{{item}}' 
#         virtualenv = '{{ pulp_install_dir }}'
#         virtualenv_command: '{{ pulp_python_interpreter }} -m venv'
#       loop:
#         - pip
#         - scikit-build
# "

curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/source-install.yml > source-install.yml

echo "Installing roles."
export ANSIBLE_ROLES_PATH="./ansible-pulp3/roles/"
ansible-galaxy install -r ./ansible-pulp3/requirements.yml

echo "Available roles."
ansible-galaxy list

echo "Starting Pulp 3 Installation."
ansible-playbook -vvv -i "${PULP3_HOST}", -u root source-install.yml 

echo "Cleaning."
popd
rm -r -f "${tempdir}"

echo "Is it working?"
curl -u admin:admin "${PULP3_HOST}":80/pulp/api/v3/status/
