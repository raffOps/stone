import json
import os
import traceback

import awswrangler as wr
import pandas as pd


def lambda_handler(event=None, context=None):
    try:
        if context:
            bucket_name_store = os.getenv("S3_BUCKET_NAME")
        else:
            bucket_name_store = "sgs-transform"
        bucket_name_load = "{}-extract".format(bucket_name_store.split("-")[0])
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


def load_df(bucket_name_load):
    dfs = []
    for file in wr.s3.list_objects(f"s3://{bucket_name_load}"):
        code = file.split("/")[-1][:-5]
        df = wr.s3.read_json(f"{file}")
        df["codigo"] = code
        dfs.append(df)
    df = pd.concat(dfs)
    return df


def transform_df(df):
    df.data = df.data.apply(lambda data: pd.to_datetime(data, yearfirst=True).date())
    return df


if __name__ == "__main__":
    lambda_handler()

