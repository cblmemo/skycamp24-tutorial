#!/usr/bin/env bash
set -e
# aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/a9w6z7w5
# gcloud auth configure-docker
docker build -t skycamp-tutorial:latest .
docker tag skycamp-tutorial:latest us-docker.pkg.dev/skycamp-skypilot-fastchat/skycamp-tutorial/skycamp-tutorial:latest
docker push  us-docker.pkg.dev/skycamp-skypilot-fastchat/skycamp-tutorial/skycamp-tutorial:latest
