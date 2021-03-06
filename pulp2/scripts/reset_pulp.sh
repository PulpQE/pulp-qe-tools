#!/bin/bash
# curl https://raw.githubusercontent.com/PulpQE/pulp-qe-tools/master/pulp2/scripts/reset_pulp.sh | bash
systemctl stop httpd pulp_workers pulp_celerybeat pulp_resource_manager qpidd
mongo pulp_database --eval 'db.dropDatabase()'
runuser --shell /bin/sh apache --command pulp-manage-db
rm -rf /var/lib/pulp/content
rm -rf /var/lib/pulp/published
systemctl start httpd pulp_workers pulp_celerybeat pulp_resource_manager qpidd
pulp-admin -v status
