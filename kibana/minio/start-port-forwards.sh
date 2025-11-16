#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/minio-service 19000:9000 -n minio &
kubectl port-forward --address 0.0.0.0 service/minio-service 19001:9001 -n minio &