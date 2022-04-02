FROM public.ecr.aws/lambda/python:3.9

RUN python -m pip install pillow awslambdaric boto3

COPY ./lambda_function.py /lambda_function.py
COPY ./__init__.py /__init__.py

WORKDIR /

ENTRYPOINT [ "python", "-m", "awslambdaric" ]

CMD ["lambda_function.lambda_handler"]