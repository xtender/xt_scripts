#!/bin/bash

cat >/lib/systemd/system/oracle.service <<EOF

[Unit]
Description=Oracle Database(s) and Listener
Requires=network.target

[Service]
Type=forking
Restart=no
ExecStart=$ORACLE_HOME/bin/dbstart $ORACLE_HOME
ExecStop=$ORACLE_HOME/bin/dbshut $ORACLE_HOME
User=oracle

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable oracle
systemctl status oracle