#!/bin/bash

if [ "$(id -u)" == "0" ]; then
    echo "JANGAN menjalankan script ini sebagai root"
    exit 1
fi

usage() {
    echo "Usage: $0 [start|stop|restart|status] [service] [optional: --local --user --host]"
    echo "   --local : untuk menjalankan script pada localhost"
    echo "   --user  : username untuk remote melalui ssh [jika tanpa --local]"
    echo "   --host  : alamat IP untuk remote melalui ssh [jika tanpa --local]"
    exit 1
}

if [ $# -eq 2 ]; then
    usage
fi

action=$1
service=$2
remote_user="username"
remote_server="server_ip"
local_flag=""

if [ "$3" == "--local" ]; then
    local_flag="true"
fi

execute() {
    case $1 in
        start)
            echo "Starting $service on $remote_server..."
            sudo systemctl start $service
            ;;
        stop)
            echo "Stopping $service on $remote_server..."
            sudo systemctl stop $service
            ;;
        restart)
            echo "Restarting $service on $remote_server..."
            sudo systemctl restart $service
            ;;
        status)
            echo "Checking status of $service on $remote_server..."
            systemctl status $service
            ;;
        *)
            usage
            ;;
    esac
}

if [ -z "$local_flag" ]; then
    if [ -z "$3" ]; then
        echo "Masukkan username untuk --user dan alamat IP untuk --host"
        echo "    --user <username> --host <IP>"
        exit 1
    fi

    if [ "$3" == "--user" ]; then
        remote_user=$4
    elif [ "$3" == "--host" ]; then
        remote_server=$4
    fi

    ssh $remote_user@$remote_server sudo execute $action
else
    remote_user=$(whoami)
    remote_server=localhost
    execute $action
fi

pesan="pengingat atas proses $1 terhadap $remote_server oleh $remote_user"
echo $pesan | mail -s "$1 $service by system" rekrutmen@javan.co.id

exit 0
