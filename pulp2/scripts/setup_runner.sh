#!/bin/bash

# Clone the repos
yum -y install python36 git attr

git clone https://github.com/pulpqe/pulp-smash
git clone https://github.com/pulpqe/pulp-2-tests

# Setup venv

python3.6 -m venv venv 
source venv/bin/activate
pip install --upgrade pip
pip install pytest pytest-html
pip install -e pulp-smash[dev]
pip install -e pulp-2-tests[dev]

# Check if smash is installed
echo '##########################################'
echo 'smash is installed'
pulp-smash settings save-path

# Set your settings for the target system and then
echo '##########################################'
echo "Set smash settings location"
echo "export PULP_SMASH_CONFIG_FILE=/root/settings.json"

echo '##########################################'
echo "Hostname is: $(hostname)"

# create settings file
echo '##########################################'
echo "Create your settings file"
echo "venv/bin/pulp-smash settings create"

# Run test runner
echo '##########################################'
echo "Run tests and save html report"
echo "venv/bin/py.test -v --color=yes --html=test_report_$(hostname).html --self-contained-html --pyargs pulp_2_tests.tests"
