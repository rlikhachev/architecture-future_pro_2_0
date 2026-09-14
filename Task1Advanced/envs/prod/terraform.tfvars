cloud_id  = "b1g*********"
folder_id = "b1g********"
zone_id   = "ru-central1-a"

vm_name     = "prod-app-01"
platform_id = "standard-v3"

core_count    = 8
core_fraction = 100
memory        = 32

image_id       = "f2e2apqlakahi25fea3v"
boot_disk_size = 20

subnet_id = "ajc2gj********"
disk_size = 100
disk_type = "network-ssd"

nat_enabled = false
preemptible = false
ssh_user    = "ubuntu"
ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsm7Zba3hqyn3J+sBaEAoL6QEsHeh4IZ41nRneZd2v6 future20-prod@homework"

labels = {
  environment = "prod"
  project     = "future-2-0"
}
