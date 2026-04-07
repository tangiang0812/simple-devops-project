#!/bin/bash

kubectl create namespace argocd
kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# These are use to set up NLB for ArgoCD server, which is required for external-dns to manage DNS records for ArgoCD server.
# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer", "loadBalancerClass": "service.k8s.aws/nlb"}}'

# kubectl annotate svc argocd-server -n argocd \
#   service.beta.kubernetes.io/aws-load-balancer-name=argocd-lb \
#   service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags="Name=argocd-lb,Environment=production,Project=argocd" \
#   external-dns.alpha.kubernetes.io/hostname=argocd.gnaig.click \
#   service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing \
#   --overwrite
# echo

# We will use Ingress to set up ALB for ArgoCD server, which is required for external-dns to manage DNS records for ArgoCD server.
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "ClusterIP"}}'
kubectl patch cm argocd-cmd-params-cm -n argocd --type merge -p '{"data": {"server.insecure": "false"}}'
# kubectl rollout restart deployment argocd-server -n argocd
# kubectl annotate svc argocd-server -n argocd \
#   alb.ingress.kubernetes.io/healthcheck-protocol=HTTP \
#   alb.ingress.kubernetes.io/healthcheck-port=traffic-port \
#   alb.ingress.kubernetes.io/healthcheck-path=/healthz \
#   --overwrite
