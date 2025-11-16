#!/bin/bash
kubectl rollout status deploy/jellyfin -n jellyfin --timeout=600s || true
EP=$(kubectl get endpoints jellyfin-service -n jellyfin -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
if [ -n "$EP" ]; then
  kubectl port-forward --address 0.0.0.0 service/jellyfin-service 18096:8096 -n jellyfin &
else
  kubectl port-forward --address 0.0.0.0 deploy/jellyfin 18096:8096 -n jellyfin &
fi