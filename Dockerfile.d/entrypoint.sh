#!/bin/ash
set -Eeuo pipefail

SSL_DB_DIR="/var/cache/squid/ssl_db"

# Create the directory if it doesn't exist
if [ ! -d "$SSL_DB_DIR" ]; then
    echo "Creating SSL DB directory $SSL_DB_DIR"
    mkdir -p "$SSL_DB_DIR"
fi

# Check if the SSL database is initialized
if [ ! -d "$SSL_DB_DIR/certs" ]; then
    echo "Initializing SSL database"
    cd /var/cache/squid
    rm -rf ssl_db
    security_file_certgen -c -s ssl_db -M 16MB
    echo "SSL database initialized successfully"
else
    echo "SSL database already initialized"
fi

# Initialize cache if needed
if [ ! -d /var/cache/squid/00 ]; then
    echo "Initializing Squid cache"
    squid -N -z
    echo "Cache initialized"
fi

# Test Squid configuration
echo "Testing Squid configuration"
squid -N -k parse

# Start Squid
echo "Starting Squid"
exec squid -N
