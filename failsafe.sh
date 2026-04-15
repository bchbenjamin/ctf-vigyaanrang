#!/usr/bin/env bash

set -euo pipefail

PLAYERS_BASE="/home/ubuntu/players"

error() {
  printf 'Error: %s\n' "$1" >&2
}

main() {
  if [[ ! -d "${PLAYERS_BASE}" ]]; then
    error "player directory does not exist: ${PLAYERS_BASE}"
    exit 1
  fi

  # Another developer will pipe this stdout stream into a Discord webhook handler.
  inotifywait --monitor --recursive --event delete --format '%w%f' "${PLAYERS_BASE}" |
    while IFS= read -r deleted_path; do
      local filename=""
      local player_dir=""
      local user_id=""

      filename="$(basename "${deleted_path}")"
      case "${filename}" in
        1.txt|2.txt)
          player_dir="$(basename "$(dirname "${deleted_path}")")"
          user_id="${player_dir#user_}"
          printf '[ALERT] %s has deleted the file %s\n' "${user_id}" "${filename}"
          ;;
        *)
          ;;
      esac
    done
}

main "$@"
