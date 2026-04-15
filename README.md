# Localized File Integrity Monitoring Workspace

This workspace contains a small Ubuntu-focused toolchain for player file monitoring and flag submission:

- `setup.sh`: installs dependencies, creates mock player directories, sets script permissions, and optionally installs the `flag` command system-wide
- `flag`: parses a compact CLI payload and POSTs structured JSON to an n8n webhook
- `failsafe.sh`: runs an event-driven file deletion monitor using `inotifywait`

## Installation

Run the setup script from the project directory:

```bash
chmod +x setup.sh
./setup.sh
```

What `setup.sh` does:

- Installs `inotify-tools` and `curl`
- Creates mock directories such as `/home/ubuntu/players/user_123/` and `/home/ubuntu/players/user_456/`
- Creates dummy files `1.txt` and `2.txt` inside each player directory
- Automatically sets executable permissions for local `flag` and `failsafe.sh` scripts
- Prompts to install `flag` into `/usr/local/bin/flag` for system-wide access

## The Flag Command

The CLI accepts a required `-d` payload and provides a built-in help menu.

```bash
# Submit a flag
flag -d 12345

# View the help menu
flag -help
```

Options:
- `-d <payload>` : Send the payload to the webhook
- `-h, -help`   : Show the usage help message

Parsing rules:

- First 3 characters: `user_id`
- Remaining characters: `flag_no`

Example:

- Input payload: `12345`
- Parsed `user_id`: `123`
- Parsed `flag_no`: `45`

The command sends a `POST` request to the configured n8n webhook using `curl`.

Exact JSON schema sent to n8n:

```json
{
  "user_id": "123",
  "flag_no": "45"
}
```

Additional examples:

```bash
flag -d 45699
flag -d 7891001
```

Error handling:

- Missing `-d` returns a non-zero exit code and writes usage details to stderr
- Payloads shorter than 4 characters are rejected
- Invalid flags (e.g., `-x`) trigger an error and display the help menu

## The FailSafe Daemon

Start the monitor locally (if not running as a system service):

```bash
./failsafe.sh
```

How it works:

- Watches `/home/ubuntu/players/` recursively
- Listens only for `delete` events
- Only reacts to deletions of `1.txt` or `2.txt`
- Extracts the player directory name from the deleted file path
- Converts a directory name like `user_123` into the user identifier `123`

Example path handling:

- Deleted file path: `/home/ubuntu/players/user_123/1.txt`
- Parsed player directory: `user_123`
- Parsed user ID: `123`

Exact stdout format for the Discord integration developer:

```text
[ALERT] 123 has deleted the file 1.txt
```

## Notes for integration:

- Alert messages are written to stdout so they can be piped directly into another process
- Script errors are written to stderr
- A comment in `failsafe.sh` marks the intended Discord webhook handoff point