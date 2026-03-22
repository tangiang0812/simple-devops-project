#!/bin/bash
# kubectl port-forward svc/argocd-server -n argocd 8080:443
# kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

ARGOCD_SERVER_URL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

printf "%s\n" "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)" | argocd login $ARGOCD_SERVER_URL --username admin --insecure

argocd repo add https://gitlab.$DOMAIN_NAME/root/$PROJECT_NAME-manifest.git \
  --username "$GITLAB_ROOT_TOKEN_KEY" \
  --password "$GITLAB_ROOT_TOKEN" \
  --project "default" \
  --name "$PROJECT_NAME-manifest"

echo "Repository $PROJECT_NAME-manifest added to Argo CD"

argocd app create $PROJECT_NAME --repo https://gitlab.$DOMAIN_NAME/root/$PROJECT_NAME-manifest.git \
  --path . --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --self-heal \
  --auto-prune \
  --sync-policy automated \
  --revision release

echo "Application $PROJECT_NAME created in Argo CD"