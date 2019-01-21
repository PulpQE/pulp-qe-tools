# Install pulp3 using the ansible installer

This recipes uses https://github.com/pulp/ansible-pulp3 roles to install Pulp 3 in a Fedora 28|29 server.

## Install Pulp 3 with only the pulp_file plugin

### Curl installer

```bash
export PULP3_HOST=<hotname or IP>
curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash
```

### Manually

Get the roles and install it

```bash
git clone https://github.com/pulp/ansible-pulp3.git
```

Apply some workarounds for known issues

``` bash
# pip should be updated
# FIXME: installer should take care of it.
sed -i -e "s/- name: Install pulpcore package from source/- name: Upgrade pip\n      pip:\n        name: pip\n        state: latest\n        virtualenv_command: '{{ pulp_python_interpreter }} -m venv'\n        virtualenv: '{{pulp_install_dir}}'\n\n    - name: Install pulpcore package from source/g" ./ansible-pulp3/roles/pulp3/tasks/install.yml

```

Install the roles

```bash
export ANSIBLE_ROLES_PATH="./ansible-pulp3/roles/"
ansible-galaxy install -r ./ansible-pulp3/requirements.yml
ansible-galaxy list
```

Clone this repository and run the playbook

```bash
git clone https://github.com/PulpQE/pulp-qe-tools.git
cd pulp-qe-tools/pulp3/install_pulp3/

export ANSIBLE_ROLES_PATH="./ansible-pulp3/roles/"
ansible-playbook -v -i <hostname or IP>, -u root source-install.yml
```

## Install with all the plugins

To install with all the set of plugins `rpm, file, docker`.

### Curl installer

```bash
export PULP3_HOST=<hotname or IP>
export PULP3_PLAYBOOK=source-install-plugins.yml
curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash
```

### Manually

Follow the same steps for manual installation described above replacing the ansible-playbook with:

```bash
...
export ANSIBLE_ROLES_PATH="./ansible-pulp3/roles/"
ansible-playbook -v -i <hostname or IP>, -u root source-install-plugins.yml
```


> NOTE: Currently the installation with all the plugins is failing. Take a look at `traceback.log` file.
