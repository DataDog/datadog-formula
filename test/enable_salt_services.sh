#!/bin/bash

if [ -f /bin/systemctl ]; then
    /bin/systemctl is-enabled salt-minion.service || (/bin/systemctl preset salt-minion.service && /bin/systemctl enable salt-minion.service)
    sleep 1
    /bin/systemctl daemon-reload
elif [ -f "/etc/init.d/salt-minion" ]; then
    /sbin/chkconfig salt-minion on
fi
