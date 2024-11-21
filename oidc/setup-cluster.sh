minikube start --driver=docker --addons=ingress --vm=true --memory=4096 --cpus=4
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --wait \
  --create-namespace \
  --namespace cert-manager \
  --set installCRDs=true

kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: keycloak
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: keycloak-selfsigned
  namespace: keycloak
  labels:
    app: keycloak
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: keycloak-selfsigned
  namespace: keycloak
  labels:
    app: keycloak
spec:
  isCA: true
  commonName: keycloak-selfsigned-ca
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: keycloak-selfsigned
    kind: Issuer
    group: cert-manager.io
  secretName: ca.crt
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  ca:
    secretName: ca.crt
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  isCA: false
  commonName: keycloak
  dnsNames:
    - keycloak.$(minikube ip).nip.io
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 4096
  issuerRef:
    kind: Issuer
    name: keycloak
    group: cert-manager.io
  secretName: keycloak.tls
  subject:
    organizations:
      - Local Eclipse Che
  usages:
    - server auth
    - digital signature
    - key encipherment
    - key agreement
    - data encipherment
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  ports:
  - name: http
    port: 8080
    targetPort: 8080
  selector:
    app: keycloak
  type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
      - name: keycloak
        image: keycloak/keycloak
        args: ["start-dev"]
        env:
        - name: KEYCLOAK_ADMIN
          value: "admin"
        - name: KEYCLOAK_ADMIN_PASSWORD
          value: "admin"
        - name: KC_PROXY_HEADERS
          value: "xforwarded"
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /realms/master
            port: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak
  namespace: keycloak
  annotations:
    nginx.ingress.kubernetes.io/proxy-connect-timeout: '3600'
    nginx.ingress.kubernetes.io/proxy-read-timeout: '3600'
    nginx.ingress.kubernetes.io/ssl-redirect: 'true'
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - keycloak.$(minikube ip).nip.io
      secretName: keycloak.tls
  rules:
  - host: keycloak.$(minikube ip).nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: keycloak
            port:
              number: 8080
EOF

kubectl get secret ca.crt -o "jsonpath={.data['ca\.crt']}" -n keycloak | base64 -d > keycloak-ca.crt

minikube ssh sudo "mkdir -p /etc/ca-certificates" && \
minikube cp keycloak-ca.crt /etc/ca-certificates/keycloak-ca.crt

minikube start \
    --extra-config=apiserver.oidc-issuer-url=https://keycloak.$(minikube ip).nip.io/realms/kubernetes \
    --extra-config=apiserver.oidc-client-id=k8s \
    --extra-config=apiserver.oidc-username-claim=name \
    --extra-config=apiserver.oidc-username-prefix=- \
    --extra-config=apiserver.oidc-groups-claim=groups \
    --extra-config=apiserver.oidc-groups-prefix= \
    --extra-config=apiserver.oidc-ca-file=/etc/ca-certificates/keycloak-ca.crt
