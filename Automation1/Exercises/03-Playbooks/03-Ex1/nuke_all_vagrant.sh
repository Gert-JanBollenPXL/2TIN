#!/usr/bin/env bash
#
# nuke_all_vagrant.sh
#
# Destroys ALL Vagrant environments and cleans ALL orphaned libvirt
# domains and VM volumes so that 'vagrant up' starts clean.
#
# Preserves: base box images (*_vagrant_box_image_*) and ISOs (*.iso)
#
# Usage:
#   ./nuke_all_vagrant.sh             dry run
#   ./nuke_all_vagrant.sh --force     actually delete
#   ./nuke_all_vagrant.sh --pool NAME storage pool (default: default)
#   ./nuke_all_vagrant.sh --quiet
#

set -euo pipefail
IFS=$'\n\t'

SCRIPT_NAME="$(basename "$0")"
FORCE=false
QUIET=false
LIBVIRT_URI="qemu:///system"
POOL_NAME="default"
LOCKDIR="${TMPDIR:-/tmp}/${SCRIPT_NAME}.lockdir"

print_usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  --force       actually delete; without this it is a dry run
  --quiet       suppress normal output
  --pool NAME   storage pool name (default: ${POOL_NAME})
  --help        show this help
EOF
}

log()  { [[ "$QUIET" == false ]] && echo "$@" || true; }
die()  { echo "Error: $*" >&2; exit 1; }

virsh_cmd() { virsh -c "$LIBVIRT_URI" "$@"; }

run_or_print() {
  local desc="$1"; shift
  if [[ "$FORCE" == false ]]; then log "DRY-RUN: $desc"; return 0; fi
  "$@"
}

acquire_lock() {
  mkdir "$LOCKDIR" 2>/dev/null || die "another instance is running"
  trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT INT TERM
}

# ---- Parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)  FORCE=true;  shift ;;
    --quiet)  QUIET=true;  shift ;;
    --pool)   [[ $# -ge 2 ]] || die "--pool requires an argument"
              POOL_NAME="$2"; shift 2 ;;
    --help)   print_usage; exit 0 ;;
    *)        die "unknown argument: $1 (use --help)" ;;
  esac
done

command -v vagrant >/dev/null 2>&1 || die "vagrant not found"
command -v virsh   >/dev/null 2>&1 || die "virsh not found"

acquire_lock

log "Libvirt URI: ${LIBVIRT_URI}"
log "Pool:        ${POOL_NAME}"
log "Mode:        $( [[ "$FORCE" == true ]] && echo 'DESTRUCTIVE (--force)' || echo 'DRY RUN' )"

# --------------------
# Step 1: Destroy ALL known Vagrant environments
# --------------------
log ""
log "Step 1: destroy all known Vagrant environments"

if [[ "$FORCE" == false ]]; then
  log "DRY-RUN: vagrant global-status --prune"
  log "DRY-RUN: vagrant destroy -f <all envs>"
else
  vagrant global-status --prune >/dev/null 2>&1 || true

  env_ids=()
  while IFS= read -r line; do
    id=$(echo "$line" | awk '{print $1}')
    [[ "$id" =~ ^[0-9a-f]{7}$ ]] && env_ids+=("$id") || true
  done < <(vagrant global-status 2>/dev/null || true)

  if [[ ${#env_ids[@]} -eq 0 ]]; then
    log "No Vagrant environments found."
  else
    for id in "${env_ids[@]}"; do
      log "Destroying Vagrant env: $id"
      vagrant destroy -f "$id" 2>/dev/null || true
    done
  fi

  vagrant global-status --prune >/dev/null 2>&1 || true
fi

# --------------------
# Step 2: Remove ALL libvirt domains
# --------------------
log ""
log "Step 2: all libvirt domains"

domains=()
while IFS= read -r d; do
  [[ -n "$d" ]] && domains+=("$d") || true
done < <(virsh_cmd list --all --name 2>/dev/null || true)

if [[ ${#domains[@]} -eq 0 ]]; then
  log "No domains found."
else
  for d in "${domains[@]}"; do
    state="$(virsh_cmd domstate "$d" 2>/dev/null || true)"
    log "Domain: $d (state: $state)"
    if [[ "${state,,}" == *running* ]]; then
      run_or_print "virsh destroy '$d'" virsh_cmd destroy "$d" >/dev/null 2>&1 || true
    fi
    run_or_print "virsh undefine '$d'" virsh_cmd undefine "$d" >/dev/null 2>&1 || true
  done
fi

# --------------------
# Step 3: Remove orphaned VM volumes (preserve box images and ISOs)
# --------------------
log ""
log "Step 3: orphaned VM volumes in pool '${POOL_NAME}'"

if ! virsh_cmd pool-info "$POOL_NAME" >/dev/null 2>&1; then
  log "Pool '${POOL_NAME}' not found — skipping."
else
  vols=()
  while IFS= read -r v; do
    [[ -n "$v" ]] && vols+=("$v") || true
  done < <(virsh_cmd vol-list "$POOL_NAME" 2>/dev/null | awk 'NR>2 && $1!="" {print $1}' || true)

  found=false
  for v in "${vols[@]+"${vols[@]}"}"; do
    # Skip base box images and ISOs
    [[ "$v" == *_vagrant_box_image_* ]] && continue
    [[ "$v" == *.iso ]]                 && continue
    log "Volume: $v"
    run_or_print "virsh vol-delete '$v' --pool '${POOL_NAME}'" \
      virsh_cmd vol-delete "$v" --pool "$POOL_NAME" >/dev/null 2>&1 || true
    found=true
  done
  [[ "$found" == true ]] || log "No orphaned volumes found."
fi

log ""
log "Done. Run 'vagrant up' to start fresh."
