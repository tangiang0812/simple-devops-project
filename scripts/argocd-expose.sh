#!/bin/bash
# kubectl port-forward svc/argocd-server -n argocd 8080:443 &
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo
echo "---- ArgoCD admin secret ----"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
echo "---- ArgoCD admin secret ----"
