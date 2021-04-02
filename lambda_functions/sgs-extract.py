import os
import traceback
import json

import requests
import awswrangler as wr
import pandas as pd


def lambda_handler(event, context):
    bucket_name = os.getenv("S3_BUCKET_NAME")
    if not bucket_name:
        bucket_name = "sgs-extract"
    url_format = "http://api.bcb.gov.br/dados/serie/bcdata.sgs.{}/dados"
    CDI_CODE = list(range(21388, 21396))
    try:
        for code in CDI_CODE:
            response = requests.get(url_format.format(code)).json()
            df = pd.DataFrame(response)
            wr.s3.to_json(df=df, path=f"s3://{bucket_name}/{code}.json")
        return {'statusCode': 200,
                'body': json.dumps('sucess')}

    except Exception as e:
        return {'statusCode': 400,
                'body': traceback.format_exc()}
