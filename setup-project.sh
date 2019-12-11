#!/bin/bash
set -x
export PROJECT_ID=$1
export PROJECT_NUM=$(gcloud projects list | grep $PROJECT_ID | egrep -o '[0-9]+$')
gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud beta services enable cloudbuild.googleapis.com
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com \
  --role roles/appengine.appAdmin
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com \
  --role roles/container.admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com \
  --role roles/storage.admin
gcloud auth configure-docker -q
gcloud container clusters create bookshelf \
    --num-nodes=2 --zone=us-central1-c


