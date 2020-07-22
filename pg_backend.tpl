# pg backend
terraform {
  backend "pg" {
    conn_str    = "postgres://$PG_USERNAME:$PG_PASSWORD@$PG_SERVER/terraform_backend"
    schema_name = "TF_SCHEMA" # this should be specific to each terraform directory
  }
}
