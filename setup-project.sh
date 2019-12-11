#!/bin/bash
set -x
export PROJECT_ID=$1
gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud beta services enable cloudbuild.googleapis.com
gcloud auth configure-docker -q
gcloud container clusters create bookshelf \
    --num-nodes=2 --zone=us-central1-c


