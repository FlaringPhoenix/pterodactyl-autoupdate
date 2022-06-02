# Pterodactyl Auto Update

Automatically update your pterodactyl panel and/or wings.

# Setup

```sh
# Download the script
curl -L -o /root/update-pterodactyl.sh https://raw.githubusercontent.com/FlaringPhoenix/pterodactyl-autoupdate/master/update-pterodactyl.sh
# Configure variables at the start of the file
nano /root/update-pterodactyl.sh
```

If you want the script to automatically run every every hour add the following to `crontab -e` and save the file.

```sh
0 * * * * bash /root/update-pterodactyl.sh >> /dev/null 2>&1
```
