#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/influxdb-service 18086:8086 -n influxdb &