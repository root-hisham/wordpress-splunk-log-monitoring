#!/usr/bin/env bash
# Run on the Ubuntu web server as root. Replace SPLUNK_IP first.
set -e
SPLUNK_IP="192.168.1.6"
DEB="splunkforwarder-9.3.2-d8bb32809498-linux-2.6-amd64.deb"

wget -O "$DEB" "https://download.splunk.com/products/universalforwarder/releases/9.3.2/linux/$DEB"
dpkg -i "$DEB"
cd /opt/splunkforwarder/bin
./splunk start --accept-license      # prompts you to create an admin user
./splunk enable boot-start
./splunk add forward-server "$SPLUNK_IP:9997"
./splunk add monitor /var/log/apache2/access.log
./splunk add monitor /var/log/apache2/error.log
ufw allow 9997/tcp && ufw reload
