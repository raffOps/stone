import os
from io import BytesIO, StringIO
from multiprocessing.pool import ThreadPool
import traceback
import json
import gc

import requests
from zipfile import ZipFile
import pandas as pd
import awswrangler as wr
from datetime import datetime


def lambda_handler(event=None, context=None):
    bucket_name = os.getenv("S3_BUCKET_NAME")
    if not bucket_name:
        bucket_name = "pgfn-extract"
    if event and event.get("remessa"):
        remessa = event["remessa"]
    else:
        remessa = "2020-12-01"
    try:
        folders = ["fgts", "previdenciario", "nao_previdenciario"]
        zips_url = ["http://dadosabertos.pgfn.gov.br/Dados_abertos_FGTS.zip",
                    "http://dadosabertos.pgfn.gov.br/Dados_abertos_Previdenciario.zip",
                    "http://dadosabertos.pgfn.gov.br/Dados_abertos_Nao_Previdenciario.zip"]

        for folder, url in zip(folders, zips_url):
            zip_response = requests.get(url)
            zip_file = ZipFile(BytesIO(zip_response.content), mode="r")
            del(zip_response)
            gc.collect()
            for filename in zip_file.namelist():
                file = zip_file.read(filename).decode("latin1")
                df = pd.read_csv(StringIO(file), sep=";")
                del(file)
                #gc.collect()
                wr.s3.to_csv(df=df, path=f"s3://{bucket_name}/{remessa}/{folder}/{filename}")
                del(df)
                gc.collect()
            zip_file.close()

        return {'status': True,
                'body': json.dumps('sucess')}

    except Exception as e:
        #print(traceback.print_exc())
        return {'status': False,
                'body': traceback.format_exc(),
                'arquivo_grande_pra_porr_': f"{folder}/{filename}"}


if __name__ == "__main__":
    lambda_handler()