resource "aws_kms_key" "key" {
  deletion_window_in_days = 10
  description             = "Athena KMS Key"
}

resource "aws_athena_workgroup" "workgroup" {
  name = "stone_data_challenge"
  force_destroy = true
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.bucket_database.bucket}/output/"
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.key.arn
      }
    }
  }
}

resource "aws_athena_database" "database" {
  name   = "divida"
  bucket = aws_s3_bucket.bucket_database.bucket
  force_destroy = true
}

####################### TABELA SGS  ##############################################

resource "aws_athena_named_query" "create_table_indicadores_divida" {
  name      = "create_table_indicadores"
  workgroup = aws_athena_workgroup.workgroup.id
  database  = aws_athena_database.database.name
  query     = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS ${aws_athena_database.database.name}.indicadores (
  `codigo` string,
  `valor` float
) PARTITIONED BY (
  data date
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
) LOCATION 's3://${var.lambda_bucket_name[1]}/'
TBLPROPERTIES ('has_encrypted_data'='false');
EOF
}

####################### TABELA PGFN  ##############################################

resource "aws_athena_named_query" "create_table_divida_ativa" {
  name      = "create_table_devedores"
  workgroup = aws_athena_workgroup.workgroup.id
  database  = aws_athena_database.database.name
  query     = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS ${aws_athena_database.database.name}.devedores (
    `tipo_pessoa` string,
    `nome_devedor` string,
    `situacao_inscricao` string,
    `data_inscricao` date,
    `origem` string,
    `valor_consolidado` float )
PARTITIONED BY (
  quarter date,
  uf_unidade_responsavel string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
WITH SERDEPROPERTIES ( 'serialization.format' = '1')
LOCATION 's3://${var.lambda_bucket_name[3]}/'
TBLPROPERTIES ('has_encrypted_data'='false')
EOF
}