#!/bin/bash
echo "Pods:"
kubectl get pods -n kafka -o wide
echo "Services:"
kubectl get svc -n kafka -o wide
echo "PVCs:"
kubectl get pvc -n kafka
echo "Events (last 50):"
kubectl get events -n kafka --sort-by=.lastTimestamp | tail -n 50