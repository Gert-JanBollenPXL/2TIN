#!/bin/bash

LOG_FILE="/tmp/auto-commit.log"
PID_FILE="/tmp/auto-commit.pid"

# Store PID
echo $$ > "$PID_FILE"

# Trap SIGTERM and SIGINT for graceful shutdown
trap 'echo "Auto-commit stopped at $(date)" >> "$LOG_FILE"; exit 0' SIGTERM SIGINT

# Log startup
echo "=== Auto-commit script started at $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
echo "Working directory: $(pwd)" >> "$LOG_FILE"
echo "Git status: $(git status -s)" >> "$LOG_FILE"

while true; do
    # Check if there are any changes
    if [[ -n $(git status -s) ]]; then
        # Get current timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Add all changes
        git add -A
        
        # Commit with timestamp
        git commit -m "Auto-commit: $timestamp" >> "$LOG_FILE" 2>&1
        
        echo "[$timestamp] Changes committed" >> "$LOG_FILE"

        git push origin main
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] No changes to commit" >> "$LOG_FILE"
    fi
    
    # Wait 5 minutes (300 seconds)
    sleep 300
done