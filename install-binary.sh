path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
source $path/env

read -p "Sure? " c
case $c in y|Y) ;; *) exit ;; esac

#install binary
cd /root
apt install npm
npm install -g synchronizer-cli
synchronize init

#create env
cd $path
[ -f env ] || cp env.sample env
nano env
