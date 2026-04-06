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