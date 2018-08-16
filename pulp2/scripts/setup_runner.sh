#!/bin/bash

# Clone the repos

git clone https://github.com/pulpqe/pulp-smash
git clone https://github.com/pulpqe/pulp-2-tests

# Setup venv

python3 -m venv venv 
source venv/bin/activate
pip install --upgrade pip
pip install pytest pytest-html
pip install -e pulp-smash[dev]
pip install -e pulp-2-tests[dev]

# Check if smash is installed
pulp-smash settings save-path

# Set your settings for the target system and then
echo "Set smash settings location"
echo "export PULP_SMASH_CONFIG_FILE=path_to_a_file.json"

# create settings file
echo "Create your settings file"
echo "pulp-smash settings create"

# Run test runner
echo "Run tests and save html report"
echo "py.test -v --color=yes --html=test_report.html --self-contained-html --pyargs pulp_2_tests.tests"
