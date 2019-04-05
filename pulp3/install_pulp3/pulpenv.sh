#!/usr/bin/env bash

PYTHONDIR="/usr/local/lib/pulp/bin"

if [ "${#@}" -eq 0 ]; then
    CMD="source $PYTHONDIR/activate"
else
    CMD="$PYTHONDIR/$@"
fi

sudo -u pulp /bin/bash -c "DJANGO_SETTINGS_MODULE=pulpcore.app.settings $CMD; DJANGO_SETTINGS_MODULE=pulpcore.app.settings exec /bin/bash -i"

