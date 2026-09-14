output "bucket" {
  description = "Имя созданного бакета (значение bucket в backend.tf)."
  value       = yandex_storage_bucket.tfstate.bucket
}

output "endpoint" {
  description = "S3-эндпоинт YOS для AWS_ENDPOINT_URL_S3."
  value       = "https://storage.yandexcloud.net"
}

output "access_key_id" {
  description = "ID статического ключа SA для AWS_ACCESS_KEY_ID."
  value       = yandex_iam_service_account_static_access_key.tfstate.access_key
}

output "access_key_secret" {
  description = "Секретный ключ для AWS_SECRET_ACCESS_KEY (только при создании, пересоздание ротит ключ)."
  value       = yandex_iam_service_account_static_access_key.tfstate.secret_key
  sensitive   = true
}
