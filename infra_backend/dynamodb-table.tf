variable "table_name_backend_terraform_locks" {
  type    = string
  default = "terraform-locks"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.table_name_backend_terraform_locks
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  point_in_time_recovery {
    enabled = true
  }
  attribute {
    name = "LockID"
    type = "S"
  }
}