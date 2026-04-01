#!/bin/bash
mkdir /home/codespace/.aws && touch /home/codespace/.aws/credentials && echo -e '[default]\nregion=us-east-1' >/home/codespace/.aws/config
# setup log links
# setup log links
LOG_SCRIPT_PATH=$(find /workspaces -name "setup-log-links.sh" -type f 2>/dev/null | head -n 1)
bash "$LOG_SCRIPT_PATH"

COMMIT_SCRIPT_PATH=$(find /workspaces -name "auto-commit.sh" -type f 2>/dev/null | head -n 1)

if [ -f "$COMMIT_SCRIPT_PATH" ]; then
    cd "$(dirname "$COMMIT_SCRIPT_PATH")/.." || exit
    setsid bash "$COMMIT_SCRIPT_PATH" > /tmp/auto-commit.log 2>&1 < /dev/null &
    SCRIPT_PID=$!
    echo "Script started with PID: $SCRIPT_PID" >> /tmp/wrapper.log

    sleep 2
fi
