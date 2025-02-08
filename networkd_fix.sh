#!/bin/bash

# Define override directory and file
OVERRIDE_DIR="/etc/systemd/system/systemd-networkd-wait-online.service.d"
OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"
BACKUP_FILE="$OVERRIDE_DIR/override.conf.bak"

# Ensure the override directory exists
sudo mkdir -p "$OVERRIDE_DIR"

# Backup existing override if it exists
if [ -f "$OVERRIDE_FILE" ]; then
    sudo cp "$OVERRIDE_FILE" "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"
fi

# Apply the fix by setting a timeout and specific interfaces
sudo tee "$OVERRIDE_FILE" > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --interface=wlp6s0 --interface=wlxf81a670c91e3 --timeout=10
EOF

echo "Override file updated: $OVERRIDE_FILE"

# Reload systemd and restart the service
sudo systemctl daemon-reload
sudo systemctl restart systemd-networkd-wait-online.service

# Check status
STATUS=$(systemctl is-active systemd-networkd-wait-online.service)
if [ "$STATUS" == "active" ]; then
    echo "Fix applied successfully."
else
    echo "Fix may not have worked. Use 'network_undo.sh' to restore previous settings."
fi
