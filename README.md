# Dyndns-config

How to set up dynamic DNS using a custom update server and Namecheap's basic DNS
for root zone administration.
Instructions for Ubuntu 16+

## Namecheap config

- Create NS record: `dyn` `ns1.sld.tld` `automatic`
- Create NS record: `dyn` `ns2.sld.tld` `automatic`
- Define where to find the NS (A-Record): `ns1` `10.0.0.1` `automatic`
- Define where to find the NS (A-Record): `ns2` `10.0.0.1` `automatic`
- Create A record for update API: `dyn-update` `10.0.0.1` `automatic`

# Install djbdns (D. J. Bernstein's DNS) containing tinydns

C.f. https://cr.yp.to/djbdns.html
```
apt install daemontools daemontools-run
apt install djbdns
# Create users
groupadd Gtinydns
groupadd Gdnslog
useradd Gtinydns --system --gid Gtinydns
useradd Gdnslog --system --gid Gdnslog
# Configure the service
tinydns-conf Gtinydns Gdnslog /etc/tinydns/ 10.0.0.1
# Start the service
cd /etc/service ; ln -sf /etc/tinydns/
svstat /etc/service/tinydns
# Add zone we delegated from Namecheap to our server
cd /etc/tinydns/
./add-ns dyn.sld.tld 10.0.0.1
# Add a host (IP to be updated by the update script)
./add-host host1.dyn.sld.tld 8.8.8.8
```

## systemd service (Ubuntu 16 [Xenial] and the like)

No delay in update.
```
sudo apt-get install inotify-tools
cp dyndns-update.service /etc/systemd/system/
service dyndns-update start
```

## cron

Delay of max. 1 min.
```
* * * * * /var/www/dyn-update/update.sh >> /var/www/status/tinydns-update.log
```

## Update server

- [Install composer](https://getcomposer.org/download/) to a `$PATH` location
  and make sure you can call it `composer` by e.g. symlinking to `composer.phar`.
- Get this repo: `git clone --recursive git@github.com:Rillke/Dyndns-config.git`
- Set up configuration:

```
cp -r web/conf ./conf
# Your turn: Add users as described in web/README.md
# ...
# Add hosts and the users who are allowed updating them
gedit conf/dyndns.hosts
# Copy index.php and adjust it.
cd web
cp examples/index.php . && gedit index.php
# Get dependencies
composer install
```

- Set up a virtual host in your PHP server and use /web as its root. HTTPS is
  highly recommended.

