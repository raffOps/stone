import os
import threading
from multiprocessing.pool import ThreadPool
import traceback
import json

import requests
from zipfile import ZipFile
import boto3


def lambda_handler(event=None, context=None):
    path = os.getcwd()
    labels = ["nao_previdenciario", "fgts", "previdenciario"]
    try:
        #get_zip_files(path, folders)
        #unzip_files(path, labels)
        upload_files(labels)
        return {'statusCode': 200,
                'body': json.dumps('sucess')}

    except Exception as e:
        return {'statusCode': 400,
                'body': traceback.format_exc()}


def get_zip_files(path, labels):
    chunk_size = 128
    zips_url = ["http://dadosabertos.pgfn.gov.br/Dados_abertos_Nao_Previdenciario.zip",
                "http://dadosabertos.pgfn.gov.br/Dados_abertos_FGTS.zip",
                "http://dadosabertos.pgfn.gov.br/Dados_abertos_Previdenciario.zip"]
    for label, url in zip(labels, zips_url):
        zip_response = requests.get(url, stream=True)
        with open(os.path.join(path, label + ".zip"), "wb") as zip_file:
            for chunk in zip_response.iter_content(chunk_size=chunk_size):
                zip_file.write(chunk)


def unzip_files(path, labels):
    for file in labels:
        filename = os.path.join(path, file+".zip")
        with ZipFile(filename, "r") as zip_file:
            zip_file.extractall(file)
        os.remove(filename)


def upload_files(labels):

    pool = ThreadPool(processes=10)
    folders_filenames = [f"{folder}/{file}" for folder in labels
                                              for file in os.listdir(folder)]
    pool.map(upload_file, folders_filenames)

    # for folder in labels:
    #     for file in os.listdir(folder):
    #         #s3.upload_file(f"{folder}/{file}", bucket_name, f"{folder}/{file}")
    #         #print(response)
    #         threading.Thread(target=upload_file, args=(f"{folder}/{file}", bucket_name)).start()


def upload_file(filepath):
    #bucket_name = os.getenv("S3_BUCKET_NAME")
    bucket_name = "pgfn-extract"
    s3 = boto3.client("s3")
    s3.upload_file(filepath, bucket_name, filepath)



lambda_handler()