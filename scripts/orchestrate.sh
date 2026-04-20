# !/bin/bash
set -e

(
  echo "[1] Get EKS credentials"
  ./eks-get-credentials.sh

  echo "[2] Install controllers in parallel"
  ./elb-controller-install.sh &
  ./external-dns-install.sh &
) &
PID1=$!

(
  echo "[3] Set up Gitlab projects"
  ./gitlab-projects-setup.sh

  echo "[4] Push projects to gitlab repositories"
  ./gitlab-push-app.sh
) &
PID2=$!

(
  echo "[5] Set up Gitlab instance runner"
  # ./gitlab-runners-setup.sh
) &
PID3=$!

# Wait for both groups
wait $PID1 || {
  echo "Group 1 failed"
  exit 1
}

# ./argocd-ingress-setup.sh

# while true; do
#   # HOSTNAME=$(kubectl get svc argocd-server -n argocd \
#   #   -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
#   sleep 5 # Race condition
#   echo giangdpetrai

#   ENDPOINT=$(kubectl get endpoints aws-load-balancer-webhook-service -n kube-system -o jsonpath='{.subsets[0].addresses[0].ip}')
#   if [ -n "$ENDPOINT" ]; then
#     echo "ALB controller is ready: $ENDPOINT"
#     break
#   fi

#   echo "Waiting for ALB controller..."
#   sleep 5
# done

echo "[6] Install ArgoCD"
sleep 20 # race condition
./argocd-install.sh
./argocd-ingress-setup.sh

wait $PID2 || {
  echo "Group 2 failed"
  exit 1
}

# sleep 400s for aws-load-balancer-controller fully set up
while true 
do
  HOSTNAME1=$(kubectl get ingress argocd-ingress -n argocd \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

  HOSTNAME2=$(kubectl get ingress argocd-server-grpc-ingress -n argocd \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

  if [ -n "$HOSTNAME1" ] && [ -n "$HOSTNAME2" ]; then
    echo "Both ALBs are ready:"
    echo "HTTP:  $HOSTNAME1"
    echo "gRPC:  $HOSTNAME2"
    break
  fi

  echo "Waiting for ArgoCD ALB hostname..."
  sleep 5
done

while true
do
  ARGOCD_DOMAIN=$(aws route53 list-resource-record-sets --hosted-zone-id $TF_VAR_route53_zone_id \
  --query "ResourceRecordSets[?Name == 'grpc-argocd.$DOMAIN_NAME.']" | jq -r ".[0].Name")

  if [ -n "$ARGOCD_DOMAIN" ] && [ "$ARGOCD_DOMAIN" != "null" ]; then
    echo "ARGOCD_DOMAIN DNS are ready: $ARGOCD_DOMAIN"
    sleep 5
    break
  fi
  echo "Waiting for ArgoCD ALB DNS..."
  sleep 5
done

echo "[7] ArgoCD set up repository and application"
# sleep 30 # Race condition
./argocd-setup-app.sh

wait $PID3 || {
  echo "Group 3 failed"
  exit 1
}
echo "[8] Expose load balancer urls for ArgoCD and Application"
./eks-get-alb-urls.sh
echo "[9] Expose ArgoCD admin secret"
./argocd-expose.sh

echo
echo "[DONE]"
