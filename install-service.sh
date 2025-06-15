path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
source $path/env

#create service
printf "[Unit]
Description=Multisynq Synchronizer headless service
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
Restart=always
RestartSec=10
ExecStart=/usr/bin/docker run --rm --name synchronizer-cli --pull always --platform linux/amd64 cdrakep/synqchronizer:latest --depin wss://api.multisynq.io/depin --sync-name $NAME --launcher $LAUNCHER --key $KEY --wallet $WALLET
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$folder.service

sudo systemctl daemon-reload
sudo systemctl enable $folder
