# Install pulp3 using the ansible installer

This recipes uses https://github.com/pulp/ansible-pulp roles to install Pulp 3 in a Fedora 28+ server.

### Curl installer

> Installs using ansible-pulp roles and playbooks from github, using selected plugins and adding dev tools like (git, httpie, vim, pcmd)

```bash
export PULP3_HOST=<hotname or IP>
export PULP3_PLUGINS=pulp-file,pulp-rpm,pulp-docker,pulp-certguard,pulp-ansible
export PULP3_DEV_TOOLS=on
curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp3/install_pulp3/install.sh | bash
```

> NOTE: The above by default installs with **rpm, file, docker, certguard, ansible** plugins. To install selected plugins please `export PULP3_PLUGINS=pulp-file,pulp-rpm`, or use `export PULP3_PLAYBOOK=name.yml` to specify custom playbook.

### Manually

> Installs using local ansible-pulp roles and local playbooks

Clone the ansible-pulp roles locally (skip if you already have it)

```bash
git clone https://github.com/pulp/ansible-pulp.git /path/to/ansible-pulp
```

Clone this repository locally

```bash
git clone https://github.com/PulpQE/pulp-qe-tools.git
cd pulp-qe-tools/pulp3/install_pulp3/
```

Install it

```bash
export PULP3_HOST=<hotname or IP>
export PULP3_INSTALL_MODE=local
export PULP3_ROLES_PATH=/path/to/ansible-pulp/
./install.sh
```

### Configure some environment variables

**Required**

```bash
# Where to install
export PULP3_HOST=<hotname or IP>
```

**Optional Variables**

```bash
# Set Pulp3 host specific api port default:24817
export PULP3_HOST_PORT=24817 # default:24817

# Set content host location and its port
export PULP3_CONTENT_HOST=<hostname or ip>  # default:${PULP3_HOST}
export PULP3_CONTENT_HOST_PORT=24816  # default:24816


# Set to use local playbooks (not from github)
export PULP3_INSTALL_MODE=local  # default: github

# To install only core change the playbook
# or use a custom playbook name
export PULP3_PLAYBOOK=source-install.yml  # default: source-install-plugins.yml

# Where did you cloned ansible-pulp (otherwise will fetch from github)
export PULP3_ROLES_PATH=/path/to/ansible-pulp/  # default: github

# comma separated list of plugin keys
# must match the key defined in the playbook
export PULP3_PLUGINS=pulp-file,pulp-docker  # default: pulp-file,pulp-rpm,pulp-docker,pulp-certguard,pulp-ansible

# Enable installation of devtools (git, httpie, ipython, pcmd, etc..)
export PULP3_DEV_TOOLS=on

# When running tasks on local macine set to `local` it is passed to `--connection` parameter
export PULP3_ANSIBLE_CONNECTION=local
```

# Dev tools

When `PULP3_DEV_TOOLS=on` is exported this installer will include:

```bash
dstat ,git ,htop ,httpie ,iotop ,jnettop ,jq ,ncdu ,tmux ,tree, wget ,vim
dnf-utils ,fd-find ,fzf ,ripgrep
django-extensions ,ipython ,ipdb
```

And also the `$ pcmd` which stands for **Pulp Command** it allows to run pulp specific commands in a single line and all the needed setup and environment will be activated.

Examples:

```bash
[root@fedora-29-pulp-3 ~]# pcmd
activate: Activates pulp Python virtualenv and enters a pulp user shell
clean: Restore pulp to a clean-installed state - THIS DESTROYS YOUR PULP DATA
dbreset: Reset the Pulp database - THIS DESTROYS YOUR PULP DATA
help: Print this help
journal: Interact with the journal for pulp-related units
    pjournal takes optional journalctl args e.g. 'pcmd journal -r', runs journal -f by default
restart: Restart all pulp-related services
run: Run a command inside pulp virtualenv e.g. 'pcmd run pip install foo'
start: Start all pulp-related services
status: Report the status of all pulp-related services
stop: Stop all pulp-related services


[root@fedora-29-pulp-3 ~]# pcmd run django-admin
sudo -u pulp DJANGO_SETTINGS_MODULE=pulpcore.app.settings /usr/local/lib/pulp/bin/django-admin

Type 'django-admin help <subcommand>' for help on a specific subcommand.

Available subcommands:

[app]
    reset-admin-password
    stage-profile-summary

...

# Want to install Pulp-Smash in your Pulp3 VM?

[root@fedora-29-pulp-3 ~]# pcmd run pip install pulp-smash
sudo -u pulp DJANGO_SETTINGS_MODULE=pulpcore.app.settings /usr/local/lib/pulp/bin/pip install pulp-smash
Collecting pulp-smash
...
```
