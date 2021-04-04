# [Data Challenge - Stone | Data Wrangling](https://drive.google.com/file/d/1D2e9djla0h920qy35fEQC44U0c9GnM7s/view?usp=sharing) 

Esse projeto usa a stack da AWS para executar o pipeline de ETL. As seguintes ferramentas foram utilizadas:
- ECR
- S3
- Lambda
- Athena
- Step Functions


Para gerar facilmente toda essa infraestrutura foi utlizado o [Terraform](https://www.terraform.io/).


## Dependências:
- Terraform: ```sudo make terraform```
- AWS CLI: ```sudo make aws```
- Docker: ```sudo make docker```

## Deploy:
- ```terraform init```
- ```terraform plan```
- ```terraform apply```    

## Pipeline

- D