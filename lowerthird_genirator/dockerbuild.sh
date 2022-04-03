docker build -t lowerthird_genirator .
docker tag lowerthird_genirator:latest 732192916662.dkr.ecr.eu-west-2.amazonaws.com/lowerthird_genirator:latest
docker push 732192916662.dkr.ecr.eu-west-2.amazonaws.com/lowerthird_genirator:latest