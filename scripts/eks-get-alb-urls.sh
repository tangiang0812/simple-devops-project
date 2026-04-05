#!/bin/bash
kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' && echo &
PID1=$!
kubectl get svc ops-inspiration-console-service -n ops-inspiration-console -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' && echo &
PID2=$!

# Wait for both groups
wait $PID1 || {
  echo "Group 1 failed"
  exit 1
}
wait $PID2 || {
  echo "Group 2 failed"
  exit 1
}
