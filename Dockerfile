#FROM public.ecr.aws/lambda/python:3.8
FROM python:3.8
ENV AWS_ACCESS_KEY_ID AKIAIVPICECFPZSSRYDA
ENV AWS_SECRET_ACCESS_KEY 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
ENV AWS_REGION us-east-1

COPY lambda_functions/*  ./
RUN pip install -r requirements.txt
CMD ["sgs-extract.lambda_handler"]
