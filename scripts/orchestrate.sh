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
  ./gitlab-runners-setup.sh
) &
PID3=$!

# Wait for both groups
wait $PID1 || {
  echo "Group 1 failed"
  exit 1
}
echo "[6] Install ArgoCD"
./argocd-install.sh

wait $PID2 || {
  echo "Group 2 failed"
  exit 1
}

# sleep 400s for aws-load-balancer-controller fully set up
while true; do
  HOSTNAME=$(kubectl get svc argocd-server -n argocd \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

  if [ -n "$HOSTNAME" ]; then
    echo "ALB is ready: $HOSTNAME"
    break
  fi

  echo "Waiting for ALB hostname..."
  sleep 5
done

echo "[7] ArgoCD set up repository and application"
./argocd-setup-app.sh

wait $PID3 || {
  echo "Group 3 failed"
  exit 1
}
echo "[8] Expose load balancer urls for ArgoCD and Application"
./eks-get-alb-urls.sh
echo "[9] Expose ArgoCD admin secret"
./argocd-expose.sh

echo "[DONE]"
