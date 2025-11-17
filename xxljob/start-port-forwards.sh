#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/xxl-job-admin-service 18080:8080 -n xxljob &