#!/bin/bash
#
# Installation script for SSL certificate renewal on Amazon Linux 2023

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_SERVICE="/etc/systemd/system/ssl-renewal.service"
SYSTEMD_TIMER="/etc/systemd/system/ssl-renewal.timer"

# Check if root
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: run as root"
   exit 1
fi

    echo "Setting up systemd service and timer"
    systemctl daemon-reload
    systemctl enable ssl-renewal.timer
    systemctl start ssl-renewal.timer
    
    echo "Timer status:"
    systemctl status ssl-renewal.timer --no-pager -l
    
    echo ""
    echo "Next run:"
    systemctl list-timers ssl-renewal.timer --no-pager
    
echo "SSL renewal setup complete"
