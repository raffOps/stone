#!/bin/bash

IMAGES_TO_DELETE=$( aws ecr list-images --region us-east-1 --repository-name sgs --filter "tagStatus=UNTAGGED" --query 'imageIds[*]' --output json )
aws ecr batch-delete-image --region us-east-1 --repository-name sgs --image-ids "$IMAGES_TO_DELETE" || true