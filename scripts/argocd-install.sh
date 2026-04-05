#!/bin/bash

kubectl create namespace argocd
kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl rollout restart deployment -n argocd

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer", "loadBalancerClass": "service.k8s.aws/nlb"}}'

kubectl annotate svc argocd-server -n argocd \
  service.beta.kubernetes.io/aws-load-balancer-name=argocd-lb \
  service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags="Name=argocd-lb,Environment=production,Project=argocd" \
  external-dns.alpha.kubernetes.io/hostname=argocd.gnaig.click \
  service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing \
  --overwrite
echo
