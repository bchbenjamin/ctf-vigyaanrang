#!/usr/bin/env bash

set -euo pipefail

PLAYERS_BASE="/home/ubuntu/players"
PLAYER_DIRS=(
  "${PLAYERS_BASE}/user_123"
  "${PLAYERS_BASE}/user_456"
  "${PLAYERS_BASE}/user_789"
)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAG_SOURCE="${SCRIPT_DIR}/flag"
FLAG_TARGET="/usr/local/bin/flag"

log() {
  printf '%s\n' "$1"
}

error() {
  printf 'Error: %s\n' "$1" >&2
}

install_packages() {
  log "Installing required packages: inotify-tools, curl"
  sudo apt-get update
  sudo apt-get install -y inotify-tools curl
}

create_mock_environment() {
  local player_dir

  log "Creating mock player directories under ${PLAYERS_BASE}"
  sudo mkdir -p "${PLAYERS_BASE}"

  for player_dir in "${PLAYER_DIRS[@]}"; do
    sudo mkdir -p "${player_dir}"
    printf 'dummy data for %s file 1\n' "$(basename "${player_dir}")" | sudo tee "${player_dir}/1.txt" >/dev/null
    printf 'dummy data for %s file 2\n' "$(basename "${player_dir}")" | sudo tee "${player_dir}/2.txt" >/dev/null
  done
}

install_flag_command() {
  local reply

  if [[ ! -f "${FLAG_SOURCE}" ]]; then
    error "flag script was not found at ${FLAG_SOURCE}"
    return 1
  fi

  read -r -p "Move the flag script to ${FLAG_TARGET} and make it executable? [y/N]: " reply
  case "${reply}" in
    [yY]|[yY][eE][sS])
      sudo install -m 0755 "${FLAG_SOURCE}" "${FLAG_TARGET}"
      log "Installed flag to ${FLAG_TARGET}"
      ;;
    *)
      log "Skipped system-wide installation of flag"
      ;;
  esac
}

main() {
  install_packages
  create_mock_environment
  install_flag_command
  log "Setup complete."
}

main "$@"
