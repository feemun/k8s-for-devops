#!/bin/bash
kubectl rollout restart deploy/kafka -n kafka
kubectl rollout status deploy/kafka -n kafka --timeout=240s