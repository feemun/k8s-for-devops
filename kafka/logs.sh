#!/bin/bash
kubectl logs -n kafka deploy/kafka -f --tail=200