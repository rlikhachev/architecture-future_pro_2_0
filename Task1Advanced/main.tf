// Защита от применения tfvars не того окружения: workspace должен совпадать
// с labels.environment из выбранного -var-file (dev/stage/prod).
check "workspace_matches_env" {
  assert {
    condition     = terraform.workspace == try(var.labels["environment"], "")
    error_message = "Активный workspace не совпадает с labels.environment из выбранного tfvars-файла. Проверьте пару workspace <-> -var-file (dev/stage/prod)."
  }
}

provider "yandex" {
  // аутентификация — YC_TOKEN из окружения (.env): принимается и OAuth, и IAM-токен
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone_id
}

module "vm" {
  source = "./modules/vm"

  name           = var.vm_name
  zone_id        = var.zone_id
  platform_id    = var.platform_id
  core_count     = var.core_count
  core_fraction  = var.core_fraction
  memory         = var.memory
  image_id       = var.image_id
  boot_disk_size = var.boot_disk_size
  subnet_id      = var.subnet_id
  disk_size      = var.disk_size
  disk_type      = var.disk_type
  nat_enabled    = var.nat_enabled
  ssh_user       = var.ssh_user
  ssh_key        = var.ssh_key
  preemptible    = var.preemptible
  labels         = var.labels
}
