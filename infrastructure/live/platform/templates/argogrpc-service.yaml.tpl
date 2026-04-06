apiVersion: v1
kind: Service
metadata:
  annotations:
    alb.ingress.kubernetes.io/backend-protocol-version: GRPC # This tells AWS to send traffic from the ALB using GRPC. Plain HTTP2 can be used, but the health checks won't be available because argo currently downgrades non-grpc calls to HTTP1
  labels:
    app: argogrpc
  name: argogrpc
  namespace: argocd
spec:
  ports:
  - name: "443"
    port: 443
    protocol: TCP
    targetPort: 8080
  selector:
    app.kubernetes.io/name: argocd-server
  sessionAffinity: None
  type: NodePort
