import json
import os
import traceback
import gc
from datetime import datetime

import awswrangler as wr
import pandas as pd

QUARTER_MONTH = [1, 4, 7, 10]


def lambda_handler(event=None, context=None):
    try:
        if context:
            bucket_name_store = os.getenv("S3_BUCKET_NAME")
        else:
            bucket_name_store = "pgfn-transform"

        bucket_name_load = "{}-extract".format(bucket_name_store.split("-")[0])
        remessa = event["remessa"]
        uf = event["uf"]
        origem = event["origem"]

        if not (isinstance(remessa, str) and isinstance(uf, str) and isinstance(origem, str)):
            raise Exception("Inputs devem serem strings")

        if origem == "nao_previdenciario" and uf == "SP":
            return {'status': True,
                        'body': 'O lambda nao consegue terminar em 15 minutos com esses parametros :(',
                        "event": event}

        print(f"{remessa} | {origem} | {uf}")
        for file in wr.s3.list_objects(f"s3://{bucket_name_load}/{remessa}/{origem}"):
            if uf == file[-13:-11]:
                df = wr.s3.read_csv(file, index_col=0)
                print(f"Download finished. File: {file}")
                df = transform_df(df, origem, remessa)
                print("Transformation finished")
                wr.s3.to_parquet(df=df,
                                 path=f"s3://{bucket_name_store}/",
                                 use_threads=True,
                                 dataset=True,
                                 compression="snappy",
                                 partition_cols=["quarter", "uf_unidade_responsavel"],
                                 dtype={
                                     "valor_consolidado": "float",
                                     "remessa": "date",
                                     "data_inscricao": "date"
                                 }
                                 )
                del(df)
                print("Upload finished")
        return {'status': True,
                'body': 'sucess',
                "event": event}

    except Exception:
        raise Exception(json.dumps(
            {
                "event": event,
                "body": traceback.format_exc()
            }
        )
        )


def transform_df(df, origem, remessa):
    df.columns = df.columns.str.strip().str.lower()
    df = df[df.data_inscricao.apply(lambda date: date[-4:] != "1000")]
    df.reset_index(drop=True, inplace=True)
    df.data_inscricao = df.data_inscricao.apply(lambda data:
                                                pd.to_datetime(data, yearfirst=True).date())
    df["quarter"] = df.data_inscricao.apply(get_quarter)
    df["remessa"] = remessa
    df["origem"] = origem
    return df


def get_quarter(date):
    return datetime(date.year, QUARTER_MONTH[pd.Timestamp(date).quarter - 1], 1).date()
    # https://www.investopedia.com/terms/q/quarter.asp


if __name__ == "__main__":
    event = {
              "uf": "PR",
              "origem": "nao_previdenciario",
              "remessa": "2020-12-01"
            }
    lambda_handler(event=event, context=True)


