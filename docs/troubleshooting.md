# Troubleshooting

| Problem | Fix |
|---|---|
| No events in Splunk | Check `sudo ./splunk list forward-server` on the Ubuntu server, confirm port 9997 is open on both the Windows firewall and UFW, and that receiving is enabled in Splunk |
| `tcp_conn_open_afux ... No such file or directory` warning when adding forward-server | Harmless warning on the first run; confirm with `./splunk list forward-server` |
| Forwarder cannot read `access.log` | Run Splunk UF as a user with read access to `/var/log/apache2/` (e.g. add `splunkfwd` to the `adm` group) |
| Apache `Could not reliably determine the server's fully qualified domain name` | Add `ServerName localhost` to `/etc/apache2/apache2.conf` |
| Admin password rejected by Splunk during setup | Password must have at least 8 printable ASCII characters |
| WordPress shows the Apache default page | Browse to `/wordpress/` or point `DocumentRoot` to `/var/www/html/wordpress` |
| `ufw` command typo | The command is `ufw`, not `uwf` |
