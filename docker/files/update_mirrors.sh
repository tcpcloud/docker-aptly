#!/bin/bash

SCRIPT=$(basename $0)
MAXTRIES=3
VERBOSE=0
SNAPSHOT=0

log_info() {
    logger -p user.info -t ${SCRIPT} "$*"
    [ $VERBOSE -eq 1 ] && echo "[INFO] $*"
}

log_error() {
    logger -p user.error -t ${SCRIPT} "$*"
    echo "[ERROR] $*" >&2
}

if [[ "$*" == *--help* || "$*" == *-h* ]]; then
    echo "Usage: ${SCRIPT} [OPTION]..."
    echo "Update mirrors and optionally create snapshots"
    echo
    echo "Available options:"
    echo "  -v, --verbose   Verbose output into terminal"
    echo "  -s, --snapshot  Create snapshot with timestamp as postfix after update"
    exit 0
fi

if [[ "$*" == *--verbose* || "$*" == *-v* ]]; then
    VERBOSE=1
fi

if [[ "$*" == *--snapshot* || "$*" == *-s* ]]; then
    SNAPSHOT=1
fi

MIRRORS=$(aptly mirror list --raw 2>&1)
if [[ $? -ne 0 ]]; then
    log_error "$MIRRORS"
    exit 1
fi

for mirror in $MIRRORS; do
    try=0
    retval=666

    while [[ $retval -ne 0 && $try -lt $MAXTRIES ]]; do
        log_info "Starting update of mirror ${mirror}"
        if [[ $VERBOSE -eq 0 ]]; then
            out=$(aptly mirror update -force=true ${mirror} >/dev/null 2>&1)
        else
            aptly mirror update -force=true ${mirror}
        fi

        retval=$?

        if [[ $retval -ne 0 ]]; then
            try=$[ $try + 1 ]
            log_error "Failed to update mirror ${mirror}, try=${try}"
            [ ! -z "$out" ] && log_error "${out}"
        else
            log_info "Synced mirror ${mirror}"
            if [[ $SNAPSHOT -eq 1 ]]; then
                snapshot_name="${mirror}-$(date +%s)"
                if [[ $VERBOSE -eq 0 ]]; then
                    out=$(aptly snapshot create ${snapshot_name} from mirror ${mirror} >/dev/null 2>&1)
                else
                    aptly snapshot create ${snapshot_name} from mirror ${mirror}
                fi

                retval=$?
                if [[ $retval -ne 0 ]]; then
                    log_error "Failed to create snapshot ${snapshot_name} from mirror ${mirror}"
                    [ ! -z "$out" ] && log_error "$out"
                else
                    log_info "Created snapshot ${snapshot_name} from mirror ${mirror}"
                fi
            fi
            break
        fi
    done
done
