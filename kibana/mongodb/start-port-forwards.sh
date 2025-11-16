#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/mongodb-service 27017:27017 -n mongodb &
