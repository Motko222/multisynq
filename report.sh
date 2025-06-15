#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/env

version=$(/usr/local/bin/synchronize -V)
service=$(sudo systemctl status $folder --no-pager | grep "active (running)" | wc -l)
errors=$(journalctl -u $folder.service --since "1 hour ago" --no-hostname -o cat | grep -c -E "rror|ERR")

synchronize points > /root/logs/multisync-points
total=$(cat /root/logs/multisync-points | grep "Total Points:" | awk '{print $NF}')

status="ok" && message=""
[ $errors -gt 500 ] && status="warning" && message="errors=$errors";
[ $service -ne 1 ] && status="error" && message="service not running";

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
       "id":"$folder-$ID",
       "machine":"$MACHINE",
       "grp":"node",
       "owner":"$OWNER"
  },
  "fields": {
        "chain":"testnet",
        "network":"testnet",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "errors":"$errors",
        "height":"",
        "m1":"total=$total",
        "m2":"",
        "m3":"",
        "url":"",
        "url1":"",
        "url2":"",
        "wallet":""    
  }
}
EOF

cat $json | jq
