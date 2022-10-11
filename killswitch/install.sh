#!/bin/sh

VPNKS='30-vpnkillswitch'
if [ -d '/etc/NetworkManager/dispatcher.d' ] ; then
    chmod ugo+x $VPNKS
    chown root:root $VPNKS
    cp $VPNKS /etc/NetworkManager/dispatcher.d
    echo "vpn kill switch installed on Network Manager"
else
    echo "vpn kill switch cannot be installed"
fi
