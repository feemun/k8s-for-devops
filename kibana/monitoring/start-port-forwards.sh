#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/grafana-service 13000:3000 -n monitoring &