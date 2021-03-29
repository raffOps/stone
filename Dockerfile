FROM public.ecr.aws/lambda/python:3.8

ENV AWS_ACCESS_KEY_ID AKIAIVPICECFPZSSRYDA
ENV AWS_SECRET_ACCESS_KEY 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
ENV AWS_REGION us-east-1

COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY sgs_lambda_function.py   ./
CMD ["sgs_lambda_function.lambda_handler"]
