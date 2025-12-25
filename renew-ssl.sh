#!/bin/bash
#
# SSL Certificate Renewal Script for justin.ae
# renew Let's Encrypt certificates and reload Apache
# Runs every 60 days on systemd.timer

set -euo pipefail

# config
DOMAIN="justin.ae"
LOG_FILE="/var/log/ssl-renewal.log"
CERTBOT_BIN="/usr/bin/certbot"
APACHE_RELOAD_CMD="systemctl reload httpd"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

log "Starting SSL certificate renewal for $DOMAIN"

if "$CERTBOT_BIN" renew --quiet --no-self-upgrade --apache --non-interactive; then
    CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    if [[ -f "$CERT_PATH" ]]; then
        EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_PATH" | cut -d= -f2)
        EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null)
        CURRENT_EPOCH=$(date +%s)
        
        if [[ -n "$EXPIRY_EPOCH" ]]; then
            DAYS_UNTIL_EXPIRY=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))
            log "Certificate expires on: $EXPIRY_DATE ($DAYS_UNTIL_EXPIRY days from now)"
            
            if [[ $DAYS_UNTIL_EXPIRY -lt 30 ]]; then
                log "WARNING: Certificate expires in less than 30 days!"
            fi
        else
            log "Could not parse certificate expiration date: $EXPIRY_DATE"
        fi
    fi
    
    if $APACHE_RELOAD_CMD; then
        log "SSL certificate renewal completed successfully"
    else
        error_exit "Failed to reload Apache."
    fi
else
    error_exit "Certificate renewal failed."
fi

log "SSL renewal complete"

