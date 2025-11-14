#!/bin/bash
# scripts/stop-port-forwards.sh

pkill -f "kubectl.*port-forward"
echo "All port-forwards stopped."