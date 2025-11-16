#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/nacos-service 18848:8848 -n nacos &