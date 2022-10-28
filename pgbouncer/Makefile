run:
	sudo docker build -t pgbouncer:latest ./
	aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin xyz.dkr.ecr.us-east-1.amazonaws.com/octank-order
	sudo docker tag pgbouncer:latest xyz.dkr.ecr.us-east-1.amazonaws.com/pgbouncer:latest
	sudo docker push xyz.dkr.ecr.us-east-1.amazonaws.com/pgbouncer:latest
