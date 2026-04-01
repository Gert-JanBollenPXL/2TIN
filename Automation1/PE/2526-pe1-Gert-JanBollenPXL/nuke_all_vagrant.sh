#!/usr/bin/env bash
#
# nuke_all_vagrant.sh
#
# Destroys all known Vagrant environments, removes all libvirt domains,
# deletes all volumes from the default storage pool, and deletes all
# non-default libvirt networks and storage pools.
# Also removes best-effort SSH known_hosts entries for discovered
# Vagrant SSH targets before the machines are destroyed.
#
# Usage:
#   ./nuke_all_vagrant.sh             dry run
#   ./nuke_all_vagrant.sh --force     actually delete
#   ./nuke_all_vagrant.sh --quiet
#

set -uo pipefail
IFS=$'\n\t'

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false
QUIET=false
LIBVIRT_URI="qemu:///system"
LOCKDIR="${TMPDIR:-/tmp}/${SCRIPT_NAME}.lockdir"
FAILURES=0
KNOWN_HOSTS_FILE="${HOME}/.ssh/known_hosts"
declare -a KNOWN_HOST_TARGETS=()
declare -A KNOWN_HOST_TARGETS_SEEN=()
COLOR_STAGE=""
COLOR_RESET=""

print_usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  --force       actually delete; without this it is a dry run
  --quiet       suppress normal output
  --help        show this help
EOF
}

log()  { [[ "$QUIET" == false ]] && echo "$@" || true; }
warn() { echo "Warning: $*" >&2; }
die()  { echo "Error: $*" >&2; exit 1; }

setup_colors() {
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    COLOR_STAGE=$'\033[1;36m'
    COLOR_RESET=$'\033[0m'
  fi
}

stage() {
  local message="$1"
  if [[ "$QUIET" == false ]]; then
    printf '\n%s%s%s\n' "$COLOR_STAGE" "$message" "$COLOR_RESET"
  fi
}

virsh_cmd() { virsh -c "$LIBVIRT_URI" "$@"; }

run_action() {
  local desc="$1"
  shift

  if [[ "$FORCE" == false ]]; then
    log "DRY-RUN: $desc"
    return 0
  fi

  log "RUN: $desc"

  local output=""
  if output=$("$@" 2>&1); then
    if [[ "$QUIET" == false && -n "$output" ]]; then
      echo "$output"
    fi
    return 0
  fi

  FAILURES=$((FAILURES + 1))
  warn "failed: $desc"
  [[ -n "$output" ]] && echo "$output" >&2
  return 1
}

capture_into() {
  local desc="$1"
  local __result_var="$2"
  shift 2

  local output=""
  if ! output=$("$@" 2>&1); then
    FAILURES=$((FAILURES + 1))
    warn "failed: $desc"
    [[ -n "$output" ]] && echo "$output" >&2
    printf -v "$__result_var" '%s' ""
    return 1
  fi

  printf -v "$__result_var" '%s' "$output"
  return 0
}

acquire_lock() {
  mkdir "$LOCKDIR" 2>/dev/null || die "another instance is running"
  trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT INT TERM
}

domain_exists() {
  virsh_cmd dominfo "$1" >/dev/null 2>&1
}

network_exists() {
  virsh_cmd net-info "$1" >/dev/null 2>&1
}

pool_exists() {
  virsh_cmd pool-info "$1" >/dev/null 2>&1
}

is_valid_port() {
  [[ "$1" =~ ^[0-9]+$ ]] && (( "$1" >= 1 && "$1" <= 65535 ))
}

register_known_host_target() {
  local target="$1"
  [[ -n "$target" ]] || return 0

  if [[ -z "${KNOWN_HOST_TARGETS_SEEN[$target]+x}" ]]; then
    KNOWN_HOST_TARGETS+=("$target")
    KNOWN_HOST_TARGETS_SEEN["$target"]=1
  fi
}

collect_known_host_targets_from_ssh_config() {
  local env_name="$1"
  local env_dir="$2"
  local ssh_config=""
  local host_alias=""
  local host_name=""
  local port=""

  register_known_host_target "$env_name"

  [[ -d "$env_dir" ]] || return 0

  if ! ssh_config="$(cd "$env_dir" && vagrant ssh-config "$env_name" 2>/dev/null)"; then
    return 0
  fi

  host_alias="$(printf '%s\n' "$ssh_config" | awk '/^Host / { print $2; exit }')"
  host_name="$(printf '%s\n' "$ssh_config" | awk '/^[[:space:]]*HostName / { print $2; exit }')"
  port="$(printf '%s\n' "$ssh_config" | awk '/^[[:space:]]*Port / { print $2; exit }')"

  register_known_host_target "$host_alias"
  register_known_host_target "$host_name"

  if is_valid_port "$port"; then
    [[ -n "$host_alias" ]] && register_known_host_target "[$host_alias]:$port"
    [[ -n "$host_name" ]] && register_known_host_target "[$host_name]:$port"
  fi
}

cleanup_known_hosts() {
  local removed_any=false
  local target=""

  if ! command -v ssh-keygen >/dev/null 2>&1; then
    warn "ssh-keygen not found; skipping known_hosts cleanup"
    return 0
  fi

  if [[ ! -f "$KNOWN_HOSTS_FILE" ]]; then
    log "No known_hosts file found at '$KNOWN_HOSTS_FILE'."
    return 0
  fi

  if [[ ${#KNOWN_HOST_TARGETS[@]} -eq 0 ]]; then
    log "No SSH known_hosts targets discovered."
    return 0
  fi

  for target in "${KNOWN_HOST_TARGETS[@]}"; do
    if ! ssh-keygen -F "$target" -f "$KNOWN_HOSTS_FILE" >/dev/null 2>&1; then
      continue
    fi

    removed_any=true

    if [[ "$FORCE" == false ]]; then
      log "DRY-RUN: ssh-keygen -R '$target' -f '$KNOWN_HOSTS_FILE'"
      continue
    fi

    if ssh-keygen -R "$target" -f "$KNOWN_HOSTS_FILE" >/dev/null 2>&1; then
      log "Removed known_hosts entry: $target"
    else
      warn "failed to remove known_hosts entry: $target"
    fi
  done

  [[ "$removed_any" == true ]] || log "No matching known_hosts entries found."
}

domain_is_active() {
  local domain_name="$1"
  local state

  state="$(virsh_cmd domstate "$domain_name" 2>/dev/null || true)"
  [[ -n "$state" && "${state,,}" != *"shut off"* ]]
}

domain_has_nvram() {
  virsh_cmd dumpxml "$1" 2>/dev/null | grep -q "<nvram>"
}

cleanup_domain() {
  local domain_name="$1"
  local state
  local undefine_args

  state="$(virsh_cmd domstate "$domain_name" 2>/dev/null || true)"
  log "Domain: $domain_name${state:+ (state: $state)}"

  if domain_is_active "$domain_name"; then
    run_action "virsh destroy '$domain_name'" virsh_cmd destroy "$domain_name"
  fi

  undefine_args=(
    undefine
    "$domain_name"
    --managed-save
    --snapshots-metadata
    --checkpoints-metadata
    --remove-all-storage
  )

  if domain_has_nvram "$domain_name"; then
    undefine_args+=(--nvram)
  fi

  run_action "virsh ${undefine_args[*]}" virsh_cmd "${undefine_args[@]}"

  if [[ "$FORCE" == true ]] && domain_exists "$domain_name"; then
    FAILURES=$((FAILURES + 1))
    warn "domain still exists after cleanup: $domain_name"
  fi
}

cleanup_network() {
  local network_name="$1"
  local state

  if [[ "$network_name" == "default" ]]; then
    log "Preserving network: $network_name"
    return 0
  fi

  state="$(virsh_cmd net-info "$network_name" 2>/dev/null | awk -F': *' '/^Active:/ {print $2}')"
  log "Network: $network_name${state:+ (active: $state)}"

  if [[ "${state,,}" == "yes" ]]; then
    run_action "virsh net-destroy '$network_name'" virsh_cmd net-destroy "$network_name"
  fi

  run_action "virsh net-undefine '$network_name'" virsh_cmd net-undefine "$network_name"

  if [[ "$FORCE" == true ]] && network_exists "$network_name"; then
    FAILURES=$((FAILURES + 1))
    warn "network still exists after cleanup: $network_name"
  fi
}

cleanup_pool_volumes() {
  local pool_name="$1"
  local found=false
  local volume_name
  local volume_output=""

  if [[ "$pool_name" != "default" ]]; then
    log "Skipping per-volume cleanup for pool '$pool_name'. It will be removed in Step 5."
    return 0
  fi

  capture_into "virsh vol-list '$pool_name'" volume_output virsh_cmd vol-list "$pool_name" || return 0

  while IFS= read -r volume_name; do
    [[ -n "$volume_name" ]] || continue

    log "Volume: $pool_name/$volume_name"
    run_action \
      "virsh vol-delete '$volume_name' --pool '$pool_name'" \
      virsh_cmd vol-delete "$volume_name" --pool "$pool_name"
    found=true
  done < <(printf '%s\n' "$volume_output" | awk 'NR > 2 && $1 != "" {print $1}')

  [[ "$found" == true ]] || log "No removable volumes found in pool '$pool_name'."
}

cleanup_pool_definition() {
  local pool_name="$1"
  local state

  if [[ "$pool_name" == "default" ]]; then
    log "Preserving pool: $pool_name"
    return 0
  fi

  state="$(virsh_cmd pool-info "$pool_name" 2>/dev/null | awk -F': *' '/^State:/ {print $2}')"
  log "Pool: $pool_name${state:+ (state: $state)}"

  if [[ "${state,,}" == "running" ]]; then
    run_action "virsh pool-destroy '$pool_name'" virsh_cmd pool-destroy "$pool_name"
  fi

  run_action "virsh pool-undefine '$pool_name'" virsh_cmd pool-undefine "$pool_name"

  if [[ "$FORCE" == true ]] && pool_exists "$pool_name"; then
    FAILURES=$((FAILURES + 1))
    warn "pool still exists after cleanup: $pool_name"
  fi
}

# ---- Parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    --quiet) QUIET=true; shift ;;
    --help) print_usage; exit 0 ;;
    *) die "unknown argument: $1 (use --help)" ;;
  esac
done

command -v vagrant >/dev/null 2>&1 || die "vagrant not found"
command -v virsh >/dev/null 2>&1 || die "virsh not found"

acquire_lock
setup_colors

log "Libvirt URI: ${LIBVIRT_URI}"
log "Mode:        $( [[ "$FORCE" == true ]] && echo 'DESTRUCTIVE (--force)' || echo 'DRY RUN' )"

stage "Step 1: discover Vagrant SSH targets and destroy all known environments"

if [[ "$FORCE" == false ]]; then
  log "DRY-RUN: collect SSH known_hosts targets from all Vagrant environments"
  log "DRY-RUN: ssh-keygen -R <discovered targets> -f '$KNOWN_HOSTS_FILE'"
  log "DRY-RUN: vagrant global-status --prune"
  log "DRY-RUN: vagrant destroy -f <all envs>"
else
  run_action "vagrant global-status --prune" vagrant global-status --prune

  env_ids=()
  env_names=()
  env_dirs=()
  vagrant_status_output=""
  if capture_into "vagrant global-status" vagrant_status_output vagrant global-status; then
    mapfile -t env_ids < <(printf '%s\n' "$vagrant_status_output" | awk '/^[0-9a-f]{7}[[:space:]]+/ {print $1}')
    mapfile -t env_names < <(printf '%s\n' "$vagrant_status_output" | awk '/^[0-9a-f]{7}[[:space:]]+/ {print $2}')
    mapfile -t env_dirs < <(printf '%s\n' "$vagrant_status_output" | awk '/^[0-9a-f]{7}[[:space:]]+/ {print $5}')
  fi

  if [[ ${#env_names[@]} -gt 0 ]]; then
    for i in "${!env_names[@]}"; do
      collect_known_host_targets_from_ssh_config "${env_names[$i]}" "${env_dirs[$i]}"
    done
  fi

  cleanup_known_hosts

  if [[ ${#env_ids[@]} -eq 0 ]]; then
    log "No Vagrant environments found."
  else
    for env_id in "${env_ids[@]}"; do
      log "Vagrant environment: $env_id"
      run_action "vagrant destroy -f '$env_id'" vagrant destroy -f "$env_id"
    done
  fi

  run_action "vagrant global-status --prune" vagrant global-status --prune
fi

stage "Step 2: remove all libvirt domains and their VM disks"

domains=()
domain_output=""
if capture_into "virsh list --all --name" domain_output virsh_cmd list --all --name; then
  mapfile -t domains < <(printf '%s\n' "$domain_output" | sed '/^$/d')
fi

if [[ ${#domains[@]} -eq 0 ]]; then
  log "No domains found."
else
  for domain_name in "${domains[@]}"; do
    cleanup_domain "$domain_name"
  done
fi

stage "Step 3: remove all volumes from the default storage pool"

pools=()
pool_output=""
if capture_into "virsh pool-list --all --name" pool_output virsh_cmd pool-list --all --name; then
  mapfile -t pools < <(printf '%s\n' "$pool_output" | sed '/^$/d')
fi

if [[ ${#pools[@]} -eq 0 ]]; then
  log "No storage pools found."
else
  for pool_name in "${pools[@]}"; do
    cleanup_pool_volumes "$pool_name"
  done
fi

stage "Step 4: remove all non-default libvirt networks"

networks=()
network_output=""
if capture_into "virsh net-list --all --name" network_output virsh_cmd net-list --all --name; then
  mapfile -t networks < <(printf '%s\n' "$network_output" | sed '/^$/d')
fi

if [[ ${#networks[@]} -eq 0 ]]; then
  log "No networks found."
else
  for network_name in "${networks[@]}"; do
    cleanup_network "$network_name"
  done
fi

stage "Step 5: remove all non-default storage pool definitions"

if [[ ${#pools[@]} -eq 0 ]]; then
  log "No storage pools found."
else
  for pool_name in "${pools[@]}"; do
    cleanup_pool_definition "$pool_name"
  done
fi

stage "Step 6: remove the local .vagrant directory for this environment"

if [[ -d "${SCRIPT_DIR}/.vagrant" ]]; then
  run_action "rm -rf '${SCRIPT_DIR}/.vagrant'" rm -rf "${SCRIPT_DIR}/.vagrant"
else
  log "No local .vagrant directory found."
fi

log ""
if [[ "$FAILURES" -gt 0 ]]; then
  warn "cleanup finished with ${FAILURES} failure(s). Review the warnings above."
  exit 1
fi

log "Done. Run 'vagrant up' to start fresh."

if [[ "$FORCE" == false ]]; then
  log "Warning: dry run only. Re-run with: ${SCRIPT_DIR}/${SCRIPT_NAME} --force"
fi
