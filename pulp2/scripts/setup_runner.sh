#!/bin/bash

# Considering you have cloned both repos:
# git clone https://github.com/pulpqe/pulp-smash
# git clone https://github.com/pulpqe/pulp-2-tests

python3 -m venv venv 
source venv/bin/activate
pip install --upgrade pip
pip install pytest pytest-html
pip install -e pulp-smash[dev]
pip install -e pulp-2-tests[dev]

pulp-smash settings save-path

# Set your settings for the target system and then
# export PULP_SMASH_CONFIG_FILE=path_to_a_file.json

# Run test runner
# py.test -v --color=yes --html=test_report.html --self-contained-html --pyargs pulp_2_tests.tests
