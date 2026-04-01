#!/bin/bash

DATA_DIR="/var/lib/pgsql/data"

if [ ! -f "$DATA_DIR/PG_VERSION" ]; then
    postgresql-setup --initdb
fi
