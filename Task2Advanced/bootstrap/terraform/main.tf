// Bootstrap: бакет состояния Terraform в Yandex Object Storage + сервисный аккаунт
// со статическими ключами. Аутентификация провайдера — из окружения (YC_TOKEN из .env).
// Результат подставляется в .env (AWS_*) и в backend.tf корневого модуля Task2Advanced.

provider "yandex" {
  // cloud_id/folder_id не задаём: ресурсы указывают folder_id явно.
  // Аутентификация — YC_TOKEN из окружения (.env): провайдер принимает и OAuth, и IAM-токен.
}

resource "yandex_iam_service_account" "tfstate" {
  folder_id   = var.folder_id
  name        = var.service_account_name
  description = "Доступ Terraform backend (S3) к бакету состояния future20"
}

resource "yandex_iam_service_account_static_access_key" "tfstate" {
  service_account_id = yandex_iam_service_account.tfstate.id
  description        = "статические ключи для backend s3 (Task2Advanced)"
}

resource "yandex_storage_bucket" "tfstate" {
  bucket        = var.bucket
  folder_id     = var.folder_id
  force_destroy = false

  // версионирование — защита состояния от случайной перезаписи/удаления
  versioning {
    enabled = true
  }

  // доступ к бакету даёт отдельный ресурс iam_member ниже (role storage.editor
  // на каталог; SA используется исключительно этим backend'ом)
}

resource "yandex_resourcemanager_folder_iam_member" "tfstate" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.tfstate.id}"
}
