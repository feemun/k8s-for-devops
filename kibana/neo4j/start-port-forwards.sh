#!/bin/bash
kubectl port-forward --address 0.0.0.0 service/neo4j-service 17474:7474 -n neo4j &
kubectl port-forward --address 0.0.0.0 service/neo4j-service 17687:7687 -n neo4j &