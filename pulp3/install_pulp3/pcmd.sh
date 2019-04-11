#!/usr/bin/env bash

# If adding new functions to this file, note that you can add help text to the function
# by defining a variable with name _<function>_help containing the help text
PYTHONDIR="/usr/local/lib/pulp/bin"
DJANGOVAR="DJANGO_SETTINGS_MODULE=pulpcore.app.settings"
SERVICES=("pulp-content-app pulp-worker@1 pulp-worker@2 pulp-resource-manager pulp-api")

_paction() {
    echo systemctl $@ ${SERVICES}
    sudo systemctl $@ ${SERVICES}
}

start() {
    _paction start
}
_start_help="Start all pulp-related services"

stop() {
    _paction stop
}
_stop_help="Stop all pulp-related services"

restart() {
    _paction restart
}
_restart_help="Restart all pulp-related services"

status() {
    _paction status
}
_status_help="Report the status of all pulp-related services"

dbreset() {
    stop
    sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/django-admin reset_db --noinput
    sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/django-admin migrate
    sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/django-admin reset-admin-password --password admin
}
_dbreset_help="Reset the Pulp database"
# can get away with not resetting terminal settings here since it gets reset in phelp
_dbreset_help="$_dbreset_help - `setterm -foreground red -bold on`THIS DESTROYS YOUR PULP DATA"

clean() {
    dbreset
    sudo rm -rf {{ pulp_user_home }}/*
    sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/django-admin collectstatic --noinput --link
}
_clean_help="Restore pulp to a clean-installed state"
# can get away with not resetting terminal settings here since it gets reset in phelp
_clean_help="$_clean_help - `setterm -foreground red -bold on`THIS DESTROYS YOUR PULP DATA"

journal() {
    # build up the journalctl cmdline per-unit
    journal_cmd="journalctl"
    for svc in ${SERVICES}; do
        journal_cmd="$journal_cmd -u $svc"
    done

    if [ -z $1 ]; then
        # not passed any args, follow the units' journals by default
        $journal_cmd -f
    else
        # passed some args, send all args through to journalctl
        $journal_cmd $@
    fi
}
_journal_help="Interact with the journal for pulp-related units
    pjournal takes optional journalctl args e.g. 'pcmd journal -r', runs journal -f by default"

activate() {
    cmd="source $PYTHONDIR/activate"
    sudo -u pulp /bin/bash -c "DJANGO_SETTINGS_MODULE=pulpcore.app.settings $cmd; DJANGO_SETTINGS_MODULE=pulpcore.app.settings exec /bin/bash -i"
}
_activate_help="Activates pulp Python virtualenv and enters a pulp user shell"

run() {
    if [ -z $1 ]; then
        # not passed any args, enters ipython
        echo "sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/ipython"
        sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/ipython
    else
        # passed some args, send all args through called binary
        # ex: `pcmd run django-admin shell` -> `sudo -u pulp DJANGO_SETTINGS_MODULE=... /var/.../bin/django-admin shell`
        echo "sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/$@"
        sudo -u pulp ${DJANGOVAR} ${PYTHONDIR}/$@
    fi
}
_run_help="Run a command inside pulp virtualenv e.g. 'pcmd run pip install foo'"

help() {
    # get a list of declared functions, filter out ones with leading underscores as "private"
    funcs=$(declare -F | awk '{ print $3 }'| grep -v ^_)

    # for each func, if a help string is defined, assume it's a pulp function and print its help
    # (this is bash introspection via variable variables)
    for func in $funcs; do
        # get the "help" variable name for this function
        help_var="_${func}_help"
        # use ${!<varname>} syntax to eval the help_var
        help=${!help_var}
        # If the help var had a value, echo its value here (the value is function help text)
        if [ ! -z "$help" ]; then
            # make the function name easy to spot
            setterm -foreground yellow -bold on
            echo -n "$func"
            # reset terminal formatting before printing the help text
            # (implicitly format it as normal text)
            setterm -default
            echo ": $help"
        fi
    done

    # explicitly restore terminal formatting is reset before exiting function
    setterm -default
}
_help_help="Print this help"


if [ "${#@}" -eq 0 ]; then
    help
else
    "$@"
fi


# Credits: Pulp-Devel Playbooks https://github.com/pulp/ansible-pulp/blob/ae27df2fe6d26f2f75daa2b72606e5f0c315d4c8/roles/pulp-devel/templates/alias.bashrc.j2
