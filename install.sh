#!/bin/sh

if [ -d '/etc/NetworkManager/dispatcher.d' ] ; then
    chmod ugo+x 30-vpnkillswitch
    chown root:root 30-vpnkillswitch
    cp 30-vpnkillswitch /etc/NetworkManager/dispatcher.d
    echo "vpn kill switch installer on Network Manager"
else
    echo "Vpn kill switch cannot be installed"
fi
