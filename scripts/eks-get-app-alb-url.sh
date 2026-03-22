#!/bin/bash
kubectl get svc ops-inspiration-console-service -n ops-inspiration-console -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'