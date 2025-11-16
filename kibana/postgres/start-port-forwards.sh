#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/postgres-service 15432:5432 -n postgres &