#!/bin/bash -e
echo "INFO: Waiting for Ubuntu daily updates to complete..."
time systemd-run --property="After=apt-daily.service apt-daily-upgrade.service" --wait /bin/true
echo "INFO: Updates are complete!"
