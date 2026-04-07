apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-grpc-ingress
  namespace: argocd
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/group.name: shared-alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: ${CERTIFICATE_ARN}
    alb.ingress.kubernetes.io/conditions.argogrpc: |
        [{"field":"http-header","httpHeaderConfig":{"httpHeaderName": "Content-Type", "values":["application/grpc"]}}]   
    # Use GRPC backend protocol for native gRPC
    alb.ingress.kubernetes.io/backend-protocol: HTTPS
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
    alb.ingress.kubernetes.io/target-type: ip
    # Enable access logs for debugging, can be turned off later if not needed. Note that the logs will be stored in the specified S3 bucket, which may incur costs.
    alb.ingress.kubernetes.io/load-balancer-attributes: health_check_logs.s3.enabled=true,health_check_logs.s3.bucket=gitlab-alb-health-logs-gnaig,access_logs.s3.enabled=true,access_logs.s3.bucket=gitlab-alb-health-logs-gnaig
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
  labels:
    app: argocd-grpc-aws-load-balancer-ingress 
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
                name: argogrpc
                port:
                  number: 443
            - host: argocd.gnaig.click
          - path: /
            pathType: Prefix  
            backend:
              service:
                name: argocd-server
                port:
                  number: 443

---
apiVersion: v1
kind: Service
metadata:
  annotations:
    alb.ingress.kubernetes.io/backend-protocol-version: GRPC #This tells AWS to send traffic from the ALB using GRPC. Can use GRPC as well if you want to leverage GRPC specific features
    # pair these 2 if you want to use /grpc.health.v1.Health/Check instead of 
    # /AWS.ALB/healthcheck with success code 12 this does not work atm =D
    # alb.ingress.kubernetes.io/healthcheck-path: /grpc.health.v1.Health/Check
    # alb.ingress.kubernetes.io/success-codes: '0'
  labels:
    app: argogrpc-service
  name: argogrpc
  namespace: argocd
spec:
  ports:
    - name: grpc
      port: 443
      protocol: TCP
      targetPort: 8080
  selector:
    app.kubernetes.io/name: argocd-server
  sessionAffinity: None
  type: ClusterIP