#!/bin/bash
kubectl apply -f "$(git rev-parse --show-toplevel)"/manifest/ingress/ingress.yaml -l app=application-aws-load-balancer-ingress
