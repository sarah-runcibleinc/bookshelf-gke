GCLOUD_PROJECT:=$(shell gcloud config list project --format="value(core.project)")

.PHONY: all
all: deploy

.PHONY: create-clusters
create-clusters:
	gcloud container clusters create bookshelf-dev \
		--scopes "cloud-platform" \
		--num-nodes 2
	gcloud container clusters create bookshelf-staging \
		--scopes "cloud-platform" \
		--num-nodes 2
	gcloud container clusters create bookshelf-prod \
		--scopes "cloud-platform" \
		--num-nodes 2

.PHONY: create-bucket
create-bucket:
	gsutil mb gs://$(GCLOUD_PROJECT)
	gsutil defacl set public-read gs://$(GCLOUD_PROJECT)

.PHONY: build
build:
	docker build -t gcr.io/$(GCLOUD_PROJECT)/bookshelf .

.PHONY: push
push: build
	gcloud docker -- push gcr.io/$(GCLOUD_PROJECT)/bookshelf

.PHONY: template
template:
	sed -i ".tmpl" "s/\[GCLOUD_PROJECT\]/$(GCLOUD_PROJECT)/g" bookshelf-frontend.yaml
	sed -i ".tmpl" "s/\[GCLOUD_PROJECT\]/$(GCLOUD_PROJECT)/g" bookshelf-worker.yaml

.PHONY: create-services
create-services:
	gcloud container clusters get-credentials bookshelf-dev
	kubectl create -f bookshelf-service.yaml
	gcloud container clusters get-credentials bookshelf-staging
	kubectl create -f bookshelf-service.yaml
	gcloud container clusters get-credentials bookshelf-prod
	kubectl create -f bookshelf-service.yaml

.PHONY: deploy-frontends
deploy-frontends: push 
	gcloud container clusters get-credentials bookshelf-dev
	kubectl create -f bookshelf-frontend.yaml
	gcloud container clusters get-credentials bookshelf-staging
	kubectl create -f bookshelf-frontend.yaml
	gcloud container clusters get-credentials bookshelf-prod
	kubectl create -f bookshelf-frontend.yaml

.PHONY: deploy-workers
deploy-workers: push 
	gcloud container clusters get-credentials bookshelf-dev
	kubectl create -f bookshelf-worker.yaml
	gcloud container clusters get-credentials bookshelf-staging
	kubectl create -f bookshelf-worker.yaml
	gcloud container clusters get-credentials bookshelf-prod
	kubectl create -f bookshelf-worker.yaml

.PHONY: deploy
deploy: deploy-frontends deploy-workers create-services

.PHONY: delete
delete:
	-kubectl delete -f bookshelf-service.yaml
	-kubectl delete -f bookshelf-worker.yaml
	-kubectl delete -f bookshelf-frontend.yaml
