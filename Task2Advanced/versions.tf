terraform {
  required_version = ">= 1.10.0" // >= 1.10 обязателен из-за use_lockfile в backend s3

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.150.0"
    }
  }
}
