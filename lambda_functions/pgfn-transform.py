import json
import os
import traceback
import gc
from datetime import datetime

import awswrangler as wr
import pandas as pd

QUARTER_MONTH = [1, 4, 7, 10]


def lambda_handler(event=None, context=None):
    bucket_name_store = os.getenv("S3_BUCKET_NAME")
    if not bucket_name_store:
        bucket_name_store = "pgfn-transform"
    bucket_name_load = "{}-extract".format(bucket_name_store.split("-")[0])

    if event:
        remessa = event["remessa"]
        estado = event["estado"]
        folder = event["folder"]
    else:
        remessa = "2020-12-01"
        estado = "MG"
        folder = "fgts"
    #folders = ["fgts", "previdenciario", "nao_previdenciario"]
    try:
        for file in wr.s3.list_objects(f"s3://{bucket_name_load}/{remessa}/{folder}"):
            if estado in file:
                df = wr.s3.read_csv(file, index_col=0)
                df = transform_df(df, folder, remessa)
                wr.s3.to_parquet(df=df,
                                 path=f"s3://{bucket_name_store}/",
                                 use_threads=True,
                                 dataset=True,
                                 compression="snappy",
                                 partition_cols=["quarter", "uf_unidade_responsavel"],
                                 #mode="overwrite_partitions",
                                 dtype={
                                     "valor_consolidado": "float",
                                     "remessa": "date",
                                     "data_inscricao": "date"
                                 }
                                 )
                del(df)
                    #gc.collect()
        return {'status': True,
                'body': json.dumps('sucess')}

    except Exception as e:
        #raise Exception(e)
        return {'status': False,
                'body': traceback.format_exc(),
                'file': file}


def transform_df(df, folder, remessa):
    df.columns = df.columns.str.strip().str.lower()
    df = df[df.data_inscricao.apply(lambda date: date[-4:] != "1000")]
    df.reset_index(drop=True, inplace=True)
    df.data_inscricao = df.data_inscricao.apply(lambda data:
                                                pd.to_datetime(data, yearfirst=True).date())
    df["quarter"] = df.data_inscricao.apply(get_quarter)
    df["remessa"] = remessa
    df["origem"] = folder
    return df


def get_quarter(date):
    return datetime(date.year, QUARTER_MONTH[pd.Timestamp(date).quarter - 1], 1).date()
    # https://www.investopedia.com/terms/q/quarter.asp


if __name__ == "__main__":
    lambda_handler()


