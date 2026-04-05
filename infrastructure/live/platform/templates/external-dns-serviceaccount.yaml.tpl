apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  namespace: external-dns
  annotations:
    eks.amazonaws.com/role-arn: ${ROLE_ARN}