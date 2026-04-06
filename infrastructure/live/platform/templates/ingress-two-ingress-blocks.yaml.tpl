apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: ops-inspiration-console
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/group.name: shared-alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: ${CERTIFICATE_ARN}
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/target-type: ip
  labels:
    app: application-aws-load-balancer-ingress
spec:
  ingressClassName: alb
  rules:
    - host: oic.gnaig.click
      http:
        paths:
          - path: /
            pathType: Prefix  
            backend:
              service:
                name: ops-inspiration-console-service
                port:
                  number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/group.name: shared-alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: ${CERTIFICATE_ARN}
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/backend-protocol: HTTPS
    # alb.ingress.kubernetes.io/backend-protocol-version: HTTP2 # This does not work with ArgoCD server for some reason, need to investigate further.
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
    alb.ingress.kubernetes.io/target-type: ip
  labels:
    app: argocd-aws-load-balancer-ingress
spec:
  ingressClassName: alb
  rules:
    - host: argocd.gnaig.click
      http:
        paths:
          - path: /
            pathType: Prefix  
            backend:
              service:
                name: argocd-server
                port:
                  number: 443
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-grpc-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/group.name: shared-alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: ${CERTIFICATE_ARN}
    alb.ingress.kubernetes.io/conditions.argocd-server: |
      [{"field":"http-header","httpHeaderConfig":{"httpHeaderName": "Content-Type", "values":["application/grpc"]}}]  
    # Use GRPC backend protocol for native gRPC
    alb.ingress.kubernetes.io/backend-protocol-version: GRPC
    alb.ingress.kubernetes.io/backend-protocol: HTTPS
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
    alb.ingress.kubernetes.io/target-type: ip
    # pair these 2 if you want to use /grpc.health.v1.Health/Check instead of 
    # /AWS.ALB/healthcheck with success code 12
    alb.ingress.kubernetes.io/healthcheck-path: /grpc.health.v1.Health/Check
    alb.ingress.kubernetes.io/success-codes: '0'
    alb.ingress.kubernetes.io/load-balancer-attributes: health_check_logs.s3.enabled=true,health_check_logs.s3.bucket=gitlab-alb-health-logs-gnaig,access_logs.s3.enabled=true,access_logs.s3.bucket=gitlab-alb-health-logs-gnaig

  labels:
    app: argocd-grpc-aws-load-balancer-ingress 
spec:
  ingressClassName: alb
  rules:
    - host: grpc-argocd.gnaig.click
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 443
