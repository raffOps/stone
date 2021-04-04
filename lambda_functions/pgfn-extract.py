import os
from io import BytesIO, StringIO
import traceback
import json
import gc

import requests
from zipfile import ZipFile
import pandas as pd
import awswrangler as wr

ZIP_URLS = {"fgts": "http://dadosabertos.pgfn.gov.br/Dados_abertos_FGTS.zip",
            "previdenciario":  "http://dadosabertos.pgfn.gov.br/Dados_abertos_Previdenciario.zip",
            "nao_previdenciario": "http://dadosabertos.pgfn.gov.br/Dados_abertos_Nao_Previdenciario.zip"
            }


def lambda_handler(event=None, context=None):
    try:
        if context:
            bucket_name = os.getenv("S3_BUCKET_NAME")
            remessa = event["remessa"]
            origem = event["origem"]
        else:
            bucket_name = "pgfn-extract"
            remessa = "2020-12-01"
            origem = "previdenciario"

        if not (isinstance(remessa, str) and isinstance(origem, str)):
            raise Exception("Input devem serem strings")

        zip_url = ZIP_URLS[origem]
        zip_response = requests.get(zip_url)
        zip_file = ZipFile(BytesIO(zip_response.content), mode="r")
        del(zip_response)
        #gc.collect()
        for filename in zip_file.namelist():
            file = zip_file.read(filename).decode("latin1")
            df = pd.read_csv(StringIO(file), sep=";")
            del(file)
            #gc.collect()
            wr.s3.to_csv(df=df, path=f"s3://{bucket_name}/{remessa}/{origem}/{filename}")
            del(df)
            #gc.collect()
        zip_file.close()

        return {'status': True,
                'body': "sucess",
                "event": event}

    except Exception:
        raise Exception(json.dumps(
            {
                "event": event,
                "body": traceback.format_exc()
            }
        )
    )


if __name__ == "__main__":
    lambda_handler()