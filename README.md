# justin.ae

Personal website and portfolio.

## Deployment

Pushing to `main` triggers the **Deploy to EC2** GitHub Action (`.github/workflows/deploy.yml`). The workflow:

1. SSHs into the EC2 instance at `18.209.196.27` using the `EC2_SSH_KEY` secret
2. Rsyncs `html/` to `/var/www/html/` and `httpd/` configs to `/etc/httpd/`
3. Reloads Apache (`httpd`)
4. Installs/updates the Let's Encrypt SSL renewal systemd timer

The site runs on **Amazon Linux EC2** with **Apache (httpd)** and **Let's Encrypt SSL**.


## Server Administration

SSH into the EC2 instance and use the following to check on things:

```bash
# Apache status
sudo systemctl status httpd

# Restart Apache
sudo systemctl restart httpd

# Apache error logs
sudo tail -f /var/log/httpd/error_log

# SSL renewal timer
sudo systemctl status ssl-renewal.timer
sudo systemctl list-timers ssl-renewal.timer

# Manually trigger SSL renewal
sudo systemctl start ssl-renewal.service

# Website root
ls /var/www/html/
```

## Running Locally

Serve the site with Python's built-in HTTP server:

```bash
python3 -m http.server 8000 --bind 0.0.0.0 --directory html
```

**Desktop:** Open [http://localhost:8000/home.html](http://localhost:8000/home.html)

**Mobile (same Wi-Fi):**

1. Find your local IP: `ipconfig getifaddr en0`
2. Open `http://<your-ip>:8000/home.html` on your phone

## Adding Photos

Photos live on the server at `/home/ec2-user/phtg/`, outside the web root, so they are **not affected by deploys**. Apache Alias directives in `justin.ae.conf` map the URL paths to this directory.

| Folder (server) | Page |
|---|---|
| `phtg/film_phtg/` | 35mm Film Photography |
| `phtg/ir_phtg/` | Infrared Photography |
| `phtg/paid_phtg/` | Hire Me (engagements, concerts, photoshoots) |

The gallery pages dynamically discover images from their folder via Apache directory listing — no HTML editing required.

### Steps to add photos

1. Drop image files (jpg, png, webp) into the appropriate folder on the server at `/home/ec2-user/phtg/`
2. Generate thumbnails on the server:

```bash
./generate_thumbs.sh /home/ec2-user/phtg/film_phtg /home/ec2-user/phtg/ir_phtg /home/ec2-user/phtg/paid_phtg
```

This creates 800px-wide thumbnails in a `thumbs/` subfolder within each directory. The script skips photos that already have a thumbnail, so it's safe to re-run.

To upload photos from your local machine:

```bash
scp -r -i ~/.ssh/justin-ae-freetier.pem <local_folder> ec2-user@18.209.196.27:/home/ec2-user/phtg/
```

4. The gallery grid uses thumbnails for display and links to the full-resolution originals on click
5. Landscape images automatically span the full grid width; portrait images display side-by-side in two columns
