.PHONY: build
build:
	@echo "\n📦 Building nfs-pod-access-control Docker image..."
	docker buildx build -t lucamiano/nfs-pod-access-control:latest .

.PHONY: push
push:
	@echo "\n📦 Pushing admission-webhook image into local registry..."
	docker push lucamiano/nfs-pod-access-control:latest


