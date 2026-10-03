resource "yandex_compute_disk" "data" {
  name   = "${var.name}-data"
  zone   = var.zone_id
  size   = var.disk_size
  type   = var.disk_type
  labels = var.labels
}

resource "yandex_compute_instance" "vm" {
  name        = var.name
  zone        = var.zone_id
  platform_id = var.platform_id
  labels      = var.labels

  resources {
    cores         = var.core_count
    core_fraction = var.core_fraction
    memory        = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.boot_disk_size
      type     = var.boot_disk_type
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat_enabled
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.data.id
    device_name = "data"
  }

  metadata = {
    ssh-keys = "${var.ssh_user}: ${var.ssh_key}"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  allow_stopping_for_update = true
}
