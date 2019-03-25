# Install pulp3 using the ansible installer

This recipes uses https://github.com/pulp/ansible-pulp roles to install Pulp 3 in a Fedora 28+ server.

### Curl installer

> Installs using ansible-pulp roles and playbooks from github

```bash
export PULP3_HOST=<hotname or IP>
curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash
```

> NOTE: The above by default installs with **rpm, file, docker and certguard** plugins. To install only core `export PULP3_PLAYBOOK=source-install.yml` use this same variable to specify a custom playbook.

### Manually

> Installs using local ansible-pulp roles and local playbooks

Clone the ansible-pulp roles locally (skip if you already have it)

```bash
git clone https://github.com/pulp/ansible-pulp.git /path/to/ansible-pulp/
```

Clone this repository locally

```bash
git clone https://github.com/PulpQE/pulp-qe-tools.git
cd pulp-qe-tools/pulp3/install_pulp3/
```

Configure some environment variables

**Required**

```bash
# Where to install
export PULP3_HOST=<hotname or IP>
# Set to use local playbooks (not from github)
export PULP3_INSTALL_MODE=local
```

**Optional**

```bash
# To install only core change the playbook
# or use a custom playbook name
export PULP3_PLAYBOOK=source-install.yml  

# Where did you cloned ansible-pulp (otherwise will fetch from github)
export PULP3_ROLES_PATH=/path/to/ansible-pulp/
```

Install it

```bash
./install.sh
```
