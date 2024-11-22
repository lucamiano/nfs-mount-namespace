.PHONY: build
build:
	@echo "\n📦 Building nfs-pod-access-control Docker image..."
	docker buildx build -t lucamiano/nfs-pod-access-control:latest .

.PHONY: push
push:
	@echo "\n📦 Pushing admission-webhook image into local registry..."
	docker push lucamiano/nfs-pod-access-control:latest

.PHONY: deploy
deploy:
	@echo "\n🚀 Deploying nfs-pod-access-control..."
	helm install nfs-pod-access-control nfs-pod-access-control

.PHONY: delete
delete:
	@echo "\n♻️  Deleting nfs-pod-access-control deployment if existing..."
	helm uninstall nfs-pod-access-control nfs-pod-access-control

.PHONY: deploy-ca
deploy-ca: 
	@echo "\n⚙️  Creating certification authority..."
	kubectl apply -f dev/manifests/cert-manager/self-signer.yaml

.PHONY: delete-ca
delete-ca:
	@echo "\n⚙️  Deleting certification authority.."
	kubectl delete -f dev/manifests/cert-manager/self-signer.yaml

.PHONY: deploy-certificate
deploy-certificate:
	@echo "\n⚙️  Creating webhook pod certificate.."
	kubectl apply -f dev/manifests/cert-manager/nfs-pod-access-control-certificate.yaml

.PHONY: delete-certificate
delete-certificate:
	@echo "\n⚙️  Deleting webhook pod certificate.."
	kubectl delete -f dev/manifests/cert-manager/nfs-pod-access-control-certificate.yaml	

.PHONY: logs
logs:
	@echo "\n🔍 Streaming nfs-pod-access-control logs..."
	kubectl logs -l app=nfs-pod-access-control -f



