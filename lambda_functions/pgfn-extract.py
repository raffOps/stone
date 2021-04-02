import os
from io import BytesIO, StringIO
from multiprocessing.pool import ThreadPool
import traceback
import json

import requests
from zipfile import ZipFile
import pandas as pd
import awswrangler as wr


def lambda_handler(event=None, context=None):
    bucket_name = os.getenv("S3_BUCKET_NAME")
    if not bucket_name:
        bucket_name = "pgfn-extract"
    try:
        folders = ["fgts", "previdenciario", "nao_previdenciario"]
        zips_url = ["http://dadosabertos.pgfn.gov.br/Dados_abertos_FGTS.zip",
                    "http://dadosabertos.pgfn.gov.br/Dados_abertos_Previdenciario.zip",
                    "http://dadosabertos.pgfn.gov.br/Dados_abertos_Nao_Previdenciario.zip"]

        for folder, url in zip(folders, zips_url):
            zip_response = requests.get(url)
            zip_file = ZipFile(BytesIO(zip_response.content), mode="r")
            for filename in zip_file.namelist():
                file = zip_file.read(filename).decode("latin1")
                df = pd.DataFrame(StringIO(file))
                wr.s3.to_csv(df=df, path=f"s3://{bucket_name}/{folder}/{filename}")
                del(df)
            zip_file.close()

        return {'statusCode': 200,
                'body': json.dumps('sucess')}

    except Exception as e:
        print(traceback.print_exc())
        return {'statusCode': 500,
                'body': traceback.format_exc()}


# def get_zip_files(folders, bucket_name):
#     chunk_size = 128
#     s3 = boto3.client("s3")
#     zips_url = ["http://dadosabertos.pgfn.gov.br/Dados_abertos_FGTS.zip",
#                 "http://dadosabertos.pgfn.gov.br/Dados_abertos_Previdenciario.zip",
#                 "http://dadosabertos.pgfn.gov.br/Dados_abertos_Nao_Previdenciario.zip"]
#     for label, url in zip(folders, zips_url):
#         zip_response = requests.get(url)
#         zip_file = ZipFile(BytesIO(zip_response.content), mode="r")
#         for filename in zip_file.namelist():
#             file = zip_file.read(filename).decode("latin1")
#             df = pd.DataFrame(StringIO(file))
#             wr.s3.to_csv(df=df, path=f"s3://{label}/{filename}")
#
# def unzip_files(folders):
#     for file in folders:
#         filename = f"{file}.zip"
#         with ZipFile(filename, "r") as zip_file:
#             zip_file.extractall(file)
#         os.remove(filename)
#
#
# # def convert_to_lgpd(folders):
# #     for folder in folders:
# #         for file in os.listdir(folder):
# #             df = pd.read_csv(os.path.join(folder, file), sep=";")
# #             print("aqui")
# #
# # def transform_cpf_cnpj(cpf_cnpj):
# #     if len(cpf_cnpj) == 12: # cpf
# #         cpf_cnpj = cpf_cnpj.replace(cpf_cnpj[:3], "***")
# #         cpf_cnpj = cpf_cnpj.replace(cpf_cnpj[:-2], "**")
# #         return cpf_cnpj
# #     elif len(cpf_cnpj) == 18: # cnpj
# #         cpf_cnpj = cpf_cnpj.replace(cpf_cnpj[:2], "**")
# #         cpf_cnpj = cpf_cnpj.replace(cpf_cnpj[3:6], "***")
# #         return cpf_cnpj
#
# def upload_files(folders):
#
#     pool = ThreadPool(processes=4)
#     folders_filenames = [f"{folder}/{file}" for folder in folders
#                                               for file in os.listdir(folder)]
#     pool.map(upload_file, folders_filenames)
#
#     # for folder in folders:
#     #     for file in os.listdir(folder):
#     #         #s3.upload_file(f"{folder}/{file}", bucket_name, f"{folder}/{file}")
#     #         #print(response)
#     #         threading.Thread(target=upload_file, args=(f"{folder}/{file}", bucket_name)).start()
#
#
# def upload_file(filepath, bucket_name):
#     #bucket_name = "pgfn-extract"
#     s3 = boto3.client("s3")
#     s3.upload_file(filepath, bucket_name, filepath)

#lambda_handler()
