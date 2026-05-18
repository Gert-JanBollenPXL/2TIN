#!/bin/sh
set -e

# Create required directories and set permissions in /media as root
mkdir -p /media/originals
chown -R nodejs:nodejs /media
chmod -R 775 /media

# Drop privileges to nodejs and exec main process
exec su-exec nodejs "$@"
