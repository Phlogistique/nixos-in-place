check_existence()
{
  set +e
  which "$1" > /dev/null 2>&1
  exists=$?
  if [ ! "$exists" -eq "0" ];
  then
    log_end "$1 not found; see the README for dependencies" 1>&2
    exit 1
  fi
  set -e
}

show_help()
{
  log "usage: $0 [OPTION...]"
  log
  log "  -h         Show this help message"
  log "  -g <dev>   Set GRUB target device (default: $grub_device)"
  log "  -r <dev>   Set root filesystem target device (default: $root_mount)"
  log "  -t <type>  Set root filesystem type (default: $root_type)"
  log "  -G         Use the graphical NixOS ISO (default: $iso)"
  log "  -d         Prepare for use with Digital Ocean (default: $digitalocean)"
  log "  -w <dir>   Specify the working directory (default: random in /tmp)"
  exit 1
}

log()
{ printf ">>> %s\n" "$*"; }
log_start()
{ printf ">>> %s" "$*"; }
log_end()
{ printf "%s\n" "$*"; }

on_exit_script() {
    local script_var=script_$BASH_SUBSHELL

    if [ -z "${!script_var:-}" ]; then
        trap "eval \"\$${script_var}\"" EXIT
    fi

    printf -v "$script_var" '%s\n%s' "$*" "${!script_var:-}"
}

on_exit() {
    on_exit_script "$(printf '%q ' "$@")"
}

mount_with_cleanup() {
    on_exit umount "${!#}"
    mount "$@"
}
