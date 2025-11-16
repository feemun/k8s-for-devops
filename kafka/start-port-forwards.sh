#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/kafka-service 19092:9092 -n kafka &