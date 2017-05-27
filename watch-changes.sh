#!/usr/bin/env bash

while inotifywait -r -e close_write /tmp/ddns_updates; do ./update.sh > /var/www/status/tinydns-update.log; done

