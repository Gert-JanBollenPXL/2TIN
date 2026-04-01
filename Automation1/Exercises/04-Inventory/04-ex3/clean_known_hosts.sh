#!/usr/bin/env bash

# clean_known_hosts.sh
#
# Removes SSH known_hosts entries for a host and ports.
#
# Default host: 127.0.0.1
# Default ports: 2222 2200 2201 2202
#
# Printing behavior:
#   - Prints "Removed [host]:port" for each removed entry
#   - If nothing matched: "No matching entries found. All good."
#   - In dry-run mode: prints "DRY-RUN: Removed [host]:port"

set -euo pipefail
IFS=$'\n\t'

DEFAULT_HOST="127.0.0.1"
DEFAULT_PORTS=(2222 2200 2201 2202)
HOST="$DEFAULT_HOST"
KNOWN_HOSTS_FILE="${HOME}/.ssh/known_hosts"

DRY_RUN=false
QUIET=false

print_usage() {
    cat <<EOF
Usage: $(basename "$0") [options] [port1 port2 ...]

Options:
  -h HOST     Host (default: $DEFAULT_HOST)
  -f FILE     known_hosts file (default: $KNOWN_HOSTS_FILE)
  -n          Dry run (do not modify file)
  -q          Quiet mode (suppress normal output)
  --help      Show this help
EOF
}

is_valid_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && (( "$1" >= 1 && "$1" <= 65535 ))
}

log() {
    if [[ "$QUIET" == false ]]; then
        echo "$@"
    fi
}

EXIT_CODE=0
PORTS=()

# --------------------
# Argument parsing
# --------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h)
            [[ $# -ge 2 ]] || { echo "Option -h requires an argument." >&2; exit 1; }
            HOST="$2"
            shift 2
            ;;
        -f)
            [[ $# -ge 2 ]] || { echo "Option -f requires an argument." >&2; exit 1; }
            KNOWN_HOSTS_FILE="$2"
            shift 2
            ;;
        -n)
            DRY_RUN=true
            shift
            ;;
        -q)
            QUIET=true
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            print_usage
            exit 1
            ;;
        *)
            PORTS+=("$1")
            shift
            ;;
    esac
done

# Use defaults if no ports specified
if [[ ${#PORTS[@]} -eq 0 ]]; then
    PORTS=("${DEFAULT_PORTS[@]}")
fi

# If file does not exist
if [[ ! -f "$KNOWN_HOSTS_FILE" ]]; then
    if [[ "$QUIET" == false ]]; then
        echo "No matching entries found. All good."
    fi
    exit 0
fi

# Ensure ssh-keygen exists
if ! command -v ssh-keygen >/dev/null 2>&1; then
    echo "Error: ssh-keygen not found." >&2
    exit 1
fi

# Sanitize host (remove surrounding brackets if user provided them)
HOST="${HOST#[}"
HOST="${HOST%]}"

removed_any=false

# --------------------
# Main loop
# --------------------
for PORT in "${PORTS[@]}"; do
    if ! is_valid_port "$PORT"; then
        EXIT_CODE=1
        continue
    fi

    TARGET="[$HOST]:$PORT"

    if ssh-keygen -F "$TARGET" -f "$KNOWN_HOSTS_FILE" >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == true ]]; then
            log "DRY-RUN: Removed $TARGET"
            removed_any=true
        else
            if ssh-keygen -R "$TARGET" -f "$KNOWN_HOSTS_FILE" >/dev/null 2>&1; then
                log "Removed $TARGET"
                removed_any=true
            else
                EXIT_CODE=1
            fi
        fi
    fi
done

if [[ "$removed_any" == false ]]; then
    if [[ "$QUIET" == false ]]; then
        echo "No matching entries found. All good."
    fi
fi

exit $EXIT_CODE