variable "name" {
  type        = string
  description = "Имя ВМ и подключаемого диска (префикс). Уникально в пределах каталога."
}

variable "zone_id" {
  type        = string
  description = "Зона доступности, в которой создаются ВМ и диск."
}

variable "platform_id" {
  type        = string
  description = "Платформа ВМ (семейство виртуализации)."
  default     = "standard-v3"
}

variable "core_count" {
  type        = number
  description = "Количество ядер CPU."

  validation {
    condition     = var.core_count >= 1 && var.core_count <= 128
    error_message = "core_count должен быть в диапазоне от 1 до 128."
  }
}

variable "core_fraction" {
  type        = number
  description = "Гарантированная доля vCPU (20, 50 или 100)."
  default     = 100

  validation {
    condition     = contains([5, 20, 25, 50, 100], var.core_fraction)
    error_message = "core_fraction должен быть одним из: 5, 20, 25, 50, 100."
  }
}

variable "memory" {
  type        = number
  description = "Объём RAM, ГБ."

  validation {
    condition     = var.memory >= 1 && var.memory <= 2048
    error_message = "memory должен быть в диапазоне от 1 до 2048 ГБ."
  }
}

variable "image_id" {
  type        = string
  description = "ID образа ОС для загрузочного диска (выбирается на уровне окружения)."
}

variable "boot_disk_size" {
  type        = number
  description = "Размер загрузочного диска, ГБ."
  default     = 10
}

variable "boot_disk_type" {
  type        = string
  description = "Тип загрузочного диска (network-hdd, network-ssd и т. д.)."
  default     = "network-ssd"
}

variable "disk_size" {
  type        = number
  description = "Размер подключаемого диска данных, ГБ."

  validation {
    condition     = var.disk_size >= 1
    error_message = "disk_size должен быть больше либо равен 1 ГБ."
  }
}

variable "disk_type" {
  type        = string
  description = "Тип подключаемого диска данных (network-hdd, network-ssd и т. д.)."
  default     = "network-hdd"
}

variable "subnet_id" {
  type        = string
  description = "ID подсети, к которой подключается ВМ."
}

variable "nat_enabled" {
  type        = bool
  description = "Назначать ли ВМ публичный IP (NAT)."
  default     = false
}

variable "ssh_user" {
  type        = string
  description = "Имя пользователя для SSH-доступа."
  default     = "ubuntu"
}

variable "ssh_key" {
  type        = string
  description = "Публичный SSH-ключ, размещаемый в метаданных ВМ."
}

variable "preemptible" {
  type        = bool
  description = "Создавать ли прерываемую ВМ (дешевле, для dev/test)."
  default     = false
}

variable "labels" {
  type        = map(string)
  description = "Метки ресурсов (например, окружение, владелец, назначение)."
  default     = {}
}
