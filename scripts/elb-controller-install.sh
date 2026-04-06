#!/bin/bash

kubectl apply -f "$(git rev-parse --show-toplevel)"/manifest/aws-load-balancer-controller/aws-load-balancer-controller-serviceaccount.yaml

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$PROJECT_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$DEFAULT_REGION" \
  --set vpcId=$(aws eks describe-cluster --name "$PROJECT_NAME" --query "cluster.resourcesVpcConfig.vpcId" --output text)
