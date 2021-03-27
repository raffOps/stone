import requests
import json
import awswrangler as wr
import pandas as pd


def lambda_handler(event, context):
    url_format = "http://api.bcb.gov.br/dados/serie/bcdata.sgs.{}/dados"
    CDI_CODE = list(range(21388, 21396))
    try:
        for code in CDI_CODE:
            response = requests.get(url_format.format(code)).json()
            df = pd.DataFrame(response)
            wr.s3.to_json(df=df, path=f"s3://rjr-sgs/{code}.json")
        return {'statusCode': 200,
                'body': json.dumps('sucess')}

    except Exception as e:
        return {'statusCode': 400,
                'body': str(e)}

