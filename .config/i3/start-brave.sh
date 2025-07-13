#!/bin/bash
# Wait for network connectivity, max 10 seconds
timeout 10s bash -c 'until ping -c 1 1.1.1.1 >/dev/null 2>&1; do sleep 1; done'
# Launch Brave
exec brave
