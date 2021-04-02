import json
import os

import awswrangler as wr
import pandas as pd



def lambda_handler(event, context):
    #bucket_name_store = os.getenv("S3_BUCKET_NAME")
    bucket_name_store = "sgs-transform"
    bucket_name_load = "{}-extract".format(bucket_name_store.split("-")[0])
    dfs = []
    for file in wr.s3.list_objects(f"s3://{bucket_name_load}")[:3]:
        code = file.split("/")[-1][:-5]
        df = wr.s3.read_json(f"{file}")
        df["codigo"] = code
        dfs.append(df)
    df = pd.concat(dfs)
    df.data = df.data.apply(lambda data: pd.to_datetime(data, yearfirst=True).date())

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
