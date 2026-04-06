#!/bin/bash
kubectl apply -f "$(git rev-parse --show-toplevel)"/manifest/argocd/ingress.yaml -l app=argocd-aws-load-balancer-ingress
kubectl apply -f "$(git rev-parse --show-toplevel)"/manifest/argocd/ingress.yaml -l app=argocd-grpc-aws-load-balancer-ingress
