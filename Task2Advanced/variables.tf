variable "cloud_id" {
  type        = string
  description = "ID облака Yandex Cloud."
}

variable "folder_id" {
  type        = string
  description = "ID каталога (folder) Yandex Cloud."
}

variable "zone_id" {
  type        = string
  description = "Зона доступности."
}

variable "vm_name" {
  type        = string
  description = "Имя ВМ в данном окружении."
}

variable "platform_id" {
  type        = string
  description = "Платформа ВМ."
}

variable "core_count" {
  type        = number
  description = "Количество ядер CPU."
}

variable "core_fraction" {
  type        = number
  description = "Гарантированная доля vCPU."
}

variable "memory" {
  type        = number
  description = "Объём RAM, ГБ."
}

variable "image_id" {
  type        = string
  description = "ID образа ОС."
}

variable "boot_disk_size" {
  type        = number
  description = "Размер загрузочного диска, ГБ."
}

variable "subnet_id" {
  type        = string
  description = "ID подсети окружения."
}

variable "disk_size" {
  type        = number
  description = "Размер подключаемого диска данных, ГБ."
}

variable "disk_type" {
  type        = string
  description = "Тип подключаемого диска данных."
}

variable "nat_enabled" {
  type        = bool
  description = "Нужен ли публичный IP (NAT)."
}

variable "ssh_user" {
  type        = string
  description = "Имя пользователя SSH."
}

variable "ssh_key" {
  type        = string
  description = "Публичный SSH-ключ."
}

variable "preemptible" {
  type        = bool
  description = "Прерываемая ВМ (дешевле)."
}

variable "labels" {
  type        = map(string)
  description = "Метки ресурсов."
}

