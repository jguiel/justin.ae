# justin.ae

Personal website and portfolio.



## Production

The site is configured to run on Apache HTTP Server with:
- DocumentRoot: `/var/www/html`
- DirectoryIndex: `home.html`
- SSL certificates via LetEncrypt

Configuration files are in the `httpd/` directory.

### SSL Certificate Renewal

The `renew-ssl.sh` script automatically renews Let's Encrypt certificates and reloads Apache.

**Manual renewal:**
```bash
sudo ./renew-ssl.sh
```

#### Automatic Renewal Setup (Amazon Linux 2023)

Amazon Linux 2023 uses **systemd timers** instead of cron. Use the automated installer:

**Recommended: Systemd Timer (Native to Amazon Linux 2023)**
```bash
sudo ./install-ssl-renewal.sh systemd
```

This will:
- Create systemd service and timer files
- Configure renewal every 60 days (runs 60 days after last successful renewal)
- Enable and start the timer automatically
- Set up proper logging

**Note:** The timer is currently configured to run every 60 days. To change the schedule, edit `/etc/systemd/system/ssl-renewal.timer` after installation.

**Alternative: Install cronie (Traditional Cron)**
If you prefer using cron:
```bash
sudo ./install-ssl-renewal.sh cronie
```

This will:
- Install cronie if not already installed
- Add a cron job for monthly renewal
- Start the cron service

#### Manual Setup (if you prefer)

**Option 1: Systemd Timer (Recommended for Amazon Linux 2023)**

1. Edit the service file to set the correct path:
   ```bash
   sudo nano ssl-renewal.service
   # Replace /path/to/justinae with actual path
   ```

2. Copy files to systemd directory:
   ```bash
   sudo cp ssl-renewal.service /etc/systemd/system/
   sudo cp ssl-renewal.timer /etc/systemd/system/
   ```

3. Enable and start:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable ssl-renewal.timer
   sudo systemctl start ssl-renewal.timer
   ```

4. Check status:
   ```bash
   sudo systemctl status ssl-renewal.timer
   sudo systemctl list-timers ssl-renewal.timer
   ```

**Option 2: Cronie (Traditional Cron)**

1. Install cronie:
   ```bash
   sudo dnf install -y cronie
   sudo systemctl enable crond
   sudo systemctl start crond
   ```

2. Edit root crontab:
   ```bash
   sudo crontab -e
   ```

3. Add entry (runs monthly on the 1st at 3 AM):
   ```cron
   0 3 1 * * /path/to/justinae/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1
   ```

   For every 6 months:
   ```cron
   0 3 1 */6 * /path/to/justinae/renew-ssl.sh >> /var/log/ssl-renewal.log 2>&1
   ```

**Note:** Let's Encrypt certificates are valid for 90 days. The script will only renew certificates that are within 30 days of expiration, so running it monthly is safe and recommended. Certbot will skip renewal if certificates are not due.

