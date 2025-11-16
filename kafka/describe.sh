#!/bin/bash
kubectl describe deploy/kafka -n kafka
kubectl describe svc/kafka-service -n kafka
kubectl describe pvc/kafka-pvc -n kafka
kubectl get pods -n kafka -o name | xargs -r -n1 kubectl describe -n kafka