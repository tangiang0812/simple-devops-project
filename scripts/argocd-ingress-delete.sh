#!/bin/bash
kubectl delete -f "$(git rev-parse --show-toplevel)"/manifest/argocd/ingress.yaml
