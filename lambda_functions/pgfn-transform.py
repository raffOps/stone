import json
import os
import traceback

import awswrangler as wr
import pandas as pd


def lambda_handler(event, context):
    bucket_name_store = os.getenv("S3_BUCKET_NAME")
    if not bucket_name_store:
        bucket_name_store = "sgs-transform"
    bucket_name_load = "{}-extract".format(bucket_name_store.split("-")[0])
    try:
        df = load_df(bucket_name_load)
        df = transform_df(df)

        wr.s3.to_parquet(df=df,
                         path=f"s3://{bucket_name_store}/",
                         dataset=True,
                         compression="snappy",
                         partition_cols=["data"],
                         mode="overwrite_partitions",
                         dtype={
                             "codigo": "string",
                             "valor": "float"
                            }
                         )
        return {'statusCode': 200,
                'body': json.dumps('sucess')}

    except Exception as e:
        return {'statusCode': 400,
                'body': traceback.format_exc()}


def load_df(bucket_name_load):
    dfs = []
    for file in wr.s3.list_objects(f"s3://{bucket_name_load}")[:3]:
        code = file.split("/")[-1][:-5]
        df = wr.s3.read_json(f"{file}")
        df["codigo"] = code
        dfs.append(df)
    df = pd.concat(dfs)
    return df


def transform_df(df):
    df.data = df.data.apply(lambda data: pd.to_datetime(data, yearfirst=True).date())
    return df

