#!/bin/bash
repository_url=${1:-633352297035.dkr.ecr.us-east-1.amazonaws.com/lambda_image}

docker build -f "lambda_functions/Dockerfile" -t lambda_image .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $repository_url
docker tag lambda_image $repository_url:latest
docker push $repository_url:latest
