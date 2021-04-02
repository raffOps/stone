import os
import traceback
import json
from io import BytesIO

import requests
import awswrangler as wr
import pandas as pd
from zipfile import ZipFile


def lambda_handler(event=None, context=None):
    path = os.getcwd()
    try:
        get_zip_files(path)
        # for code in CDI_CODE:
        #     response = requests.get(url_format.format(code)).json()
        #     df = pd.DataFrame(response)
        #     wr.s3.to_json(df=df, path=f"s3://{bucket_name}/{code}.json")
        return {'statusCode': 200,
                'body': json.dumps('sucess')}

    except Exception as e:
        return {'statusCode': 400,
                'body': traceback.format_exc()}


def get_zip_files(path):
    chunk_size = 128
    zips_url = [("nao_previdenciario", "http://dadosabertos.pgfn.gov.br/Dados_abertos_Nao_Previdenciario.zip"),
                ("fgts", "http://dadosabertos.pgfn.gov.br/Dados_abertos_FGTS.zip"),
                ("previdenciario", "http://dadosabertos.pgfn.gov.br/Dados_abertos_Previdenciario.zip")
                ]
    for label, url in zips_url:
        zip_response = requests.get(url, stream=True)
        with open(os.path.join(path, label + ".zip"), "wb") as zip_file:
            for chunk in zip_response.iter_content(chunk_size=chunk_size):
                zip_file.write(chunk)

lambda_handler()