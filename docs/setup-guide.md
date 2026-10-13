# Setup Guide

Replace every `<placeholder>` with your own value. Never commit real passwords.

## Prerequisites

- Ubuntu Server 24.04 LTS (1 GHz 64-bit CPU, 1-2 GB RAM, 10 GB+ disk), static IP
- A second machine for Splunk Enterprise
- Ports: 80, 443 (web), 22 (SSH), 9997 (Splunk forwarding)

## 1. Update and firewall

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install ufw -y
sudo ufw allow 'Apache Full'
sudo ufw allow 22/tcp
sudo ufw allow 9997/tcp
sudo ufw enable
```

## 2. Apache2

```bash
sudo apt install apache2 -y
sudo systemctl status apache2
```
Open `http://<server-ip>/`. You should see the Apache default page (`screenshots/01`).

## 3. MySQL

```bash
sudo apt install mysql-server -y
sudo systemctl status mysql
sudo mysql -u root -p
```

```sql
CREATE DATABASE wordpress_db;
CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY '<strong-password>';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## 4. PHP and WordPress

```bash
sudo apt install php php-mysql libapache2-mod-php -y
wget https://wordpress.org/latest.zip
sudo apt install unzip -y && unzip latest.zip
sudo mv wordpress /var/www/html/
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress
```

## 5. Apache virtual host and wp-config

```bash
sudo nano /etc/apache2/sites-available/wordpress.conf   # see configs/wordpress.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo nano /var/www/html/wordpress/wp-config.php         # see configs/wp-config-snippet.php
sudo systemctl restart apache2
```

## 6. WordPress installer

Visit `http://<server-ip>/wordpress/`, pick a language, then enter site title, admin username, a strong password and email. Log in to reach the dashboard.

## 7. Splunk Enterprise (monitoring machine)

1. Download Splunk Enterprise from splunk.com (60-day trial, 500 MB/day).
2. Install and open `http://127.0.0.1:8000`, log in with the admin account.
3. **Settings > Forwarding and receiving > Configure receiving > New Receiving Port**, enter `9997`, Save.
4. **Settings > Server controls > Restart Splunk**.
5. Windows Defender Firewall > Advanced settings > Inbound Rules > New Rule > Port > TCP `9997` > Allow.

## 8. Universal Forwarder (Ubuntu server)

```bash
wget -O splunkforwarder-9.3.2-d8bb32809498-linux-2.6-amd64.deb \
  "https://download.splunk.com/products/universalforwarder/releases/9.3.2/linux/splunkforwarder-9.3.2-d8bb32809498-linux-2.6-amd64.deb"
sudo dpkg -i splunkforwarder-9.3.2-d8bb32809498-linux-2.6-amd64.deb
cd /opt/splunkforwarder/bin
sudo ./splunk start --accept-license
sudo ./splunk enable boot-start
sudo ./splunk add forward-server <splunk-ip>:9997
sudo ./splunk add monitor /var/log/apache2/access.log
sudo ./splunk add monitor /var/log/apache2/error.log
```

> **Alternative (single host):** if Splunk runs on the web server itself, skip the forwarder and add monitors directly:
> `sudo /opt/splunk/bin/splunk add monitor /var/log/apache2/access.log -index main -sourcetype access_combined`

## 9. Generate and detect events

**Failed logins:** enter a wrong password a few times on `/wordpress/wp-login.php`.

**WPScan (from Kali):**
```bash
wpscan --url http://<server-ip>/wordpress/wp-login.php -e
```

**SQLMap (from Kali):**
```bash
sqlmap --url "http://<server-ip>/wordpress" --dbs --batch
```

Then search in Splunk using [`../queries/splunk-searches.spl`](../queries/splunk-searches.spl).
