.PHONY: test
test:
	@echo "\n🛠️  Running unit tests..."
	go test ./...

.PHONY: build
build:
	@echo "\n📦 Building envd-server-pod-webhook Docker image..."
	docker buildx build -t cka-control-1:5000/envd-server-pod-webhook:latest .

.PHONY: push
push:
	@echo "\n📦 Pushing admission-webhook image into local registry..."
	docker push cka-control-1:5000/envd-server-pod-webhook:latest

.PHONY: deploy-config
deploy-config:
	@echo "\n⚙️  Applying cluster config..."
	kubectl apply -f dev/manifests/cluster-config/

.PHONY: delete-config
delete-config:
	@echo "\n♻️  Deleting Kubernetes cluster config..."
	kubectl delete -f dev/manifests/cluster-config/

.PHONY: deploy
deploy: push delete delete-config deploy-config
	@echo "\n🚀 Deploying envd-server-pod-webhook..."
	kubectl apply -f dev/manifests/webhook/

.PHONY: delete
delete:
	@echo "\n♻️  Deleting envd-server-pod-webhook deployment if existing..."
	kubectl delete -f dev/manifests/webhook/ || true

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
	kubectl apply -f dev/manifests/cert-manager/envd-server-pod-webhook-certificate.yaml

.PHONY: delete-certificate
delete-certificate:
	@echo "\n⚙️  Deleting webhook pod certificate.."
	kubectl delete -f dev/manifests/cert-manager/envd-server-pod-webhook-certificate.yaml	

.PHONY: deploy-accounts
deploy-accounts:
	@echo "\n⚙️  Creating Service Accounts and assign roles.."
	sh dev/manifests/accounts/create.sh

.PHONY: delete-accounts
delete-accounts:
	@echo "\n⚙️  Deleting Service Accounts and assigned roles.."
	sh dev/manifests/accounts/delete.sh	

.PHONY: extract-tokens
extract-tokens:
	@echo "\n⚙️  Extracting tokens for Service Accounts.."
	sh dev/manifests/accounts/extract-token.sh

.PHONY: delete-all
delete-all: delete delete-config delete-certificate delete-ca delete-accounts
	@echo "\n⚙️  Deleting all..."

.PHONY: logs
logs:
	@echo "\n🔍 Streaming envd-server-pod-webhook logs..."
	kubectl logs -l app=envd-server-pod-webhook -f



