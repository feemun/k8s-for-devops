#!/bin/bash
# scripts/start-port-forwards.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
SERVICE_FILE="$SCRIPT_DIR/services.txt"

mkdir -p "$LOG_DIR"

echo "=== Starting Kubernetes NodePort forwards ==="

while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  read -r service namespace local_port target_port <<< "$line"

  echo "Processing: $service ($namespace) -> 0.0.0.0:$local_port"

  if pgrep -f "kubectl.*port-forward.*$service.*$local_port:$target_port"; then
    echo "  ⚠️  Already running: $service"
    continue
  fi

  nohup kubectl port-forward --address 0.0.0.0 "service/$service" "$local_port:$target_port" -n "$namespace" \
    > "$LOG_DIR/${service}.log" 2>&1 &

  echo "  ✅ Started: $service on :$local_port"

done < "$SERVICE_FILE"

echo "=== All services processed ==="