#!/bin/bash
pkill -f "kubectl.*port-forward.*grafana" || true
echo "Grafana port-forward stopped."