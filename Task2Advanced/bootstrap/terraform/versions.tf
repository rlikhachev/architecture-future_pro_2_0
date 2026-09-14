terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.150.0"
    }
  }

  # Состояние bootstrap-стека намеренно локальное (bootstrap.tfstate в этой папке,
  # в git не попадает): именно этот стек создаёт бакет для удалённого состояния —
  # «курица и яйцо» решаются тем, что бутстрап-состояние самое маленькое и одноразовое.
  backend "local" {}
}
