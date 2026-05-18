#!/bin/bash
set -e

echo "Initializing pxlcensor database..."

# Run all SQL files in order
for file in /docker-entrypoint-initdb.d/*.sql; do
  echo "Running $file"
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$file"
done

echo "Database initialization complete!"