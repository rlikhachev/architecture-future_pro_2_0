variable "folder_id" {
  type        = string
  description = "ID каталога Yandex Cloud, в котором создаются бакет состояния и сервисный аккаунт."
}

variable "bucket" {
  type        = string
  description = "Имя бакета Object Storage для состояний Terraform (в YOS имена глобально уникальны)."
  default     = "future20-tfstate-b1g*********"
}

variable "service_account_name" {
  type        = string
  description = "Имя сервисного аккаунта с доступом к бакету состояния."
  default     = "future20-tfstate"
}

