#!/bin/bash

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update 

kubectl create namespace external-dns
kubectl apply -f $PWD/../manifest/external-dns/external-dns-serviceaccount.yaml

helm install external-dns external-dns/external-dns \
  -n external-dns \
  --set provider=aws \
  --set aws.region="$DEFAULT_REGION" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=external-dns \
  --set domainFilters[0]="$DOMAIN_NAME" \
  --set txtOwnerId=eks-cluster \
  --set policy=sync
