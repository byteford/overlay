docker build -t lowerthird_genirator .
docker tag lowerthird_genirator:latest 630895193694.dkr.ecr.eu-west-2.amazonaws.com/lowerthird_genirator:latest
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 630895193694.dkr.ecr.eu-west-2.amazonaws.com
docker push 630895193694.dkr.ecr.eu-west-2.amazonaws.com/lowerthird_genirator:latest