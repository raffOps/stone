build_sgs:
	docker build -f sgs.Dockerfile -t sgs .
	docker run -d -p 9000:8080  sgs:latest

test_sgs:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

deploy_sgs:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 633352297035.dkr.ecr.us-east-1.amazonaws.com
	docker build -f sgs.Dockerfile -t sgs .
	docker tag sgs:latest 633352297035.dkr.ecr.us-east-1.amazonaws.com/sgs:latest
	docker push 633352297035.dkr.ecr.us-east-1.amazonaws.com/sgs:latest
	./deleta_imagens_sgs.sh
	aws lambda update-function-code --function-name s3gs-extract --image-uri 633352297035.dkr.ecr.us-east-1.amazonaws.com/sgs:latest

delete_image:
	aws ecr batch-delete-image --repository-name sgs --image-ids imageTag=latest