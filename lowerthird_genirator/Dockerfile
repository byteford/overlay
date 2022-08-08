FROM public.ecr.aws/lambda/python:3.9

RUN python -m pip install pillow awslambdaric boto3 aws_xray_sdk

COPY ./lambda_function.py /lambda_function.py

WORKDIR /

ENTRYPOINT [ "python", "-m", "awslambdaric" ]

CMD ["lambda_function.lambda_handler"]