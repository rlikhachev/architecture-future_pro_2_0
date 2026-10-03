cloud_id  = "b1g*********"
folder_id = "b1g********"
zone_id   = "ru-central1-a"

vm_name     = "dev-app-01"
platform_id = "standard-v3"

core_count    = 2
core_fraction = 20
memory        = 2

image_id       = "f2e2apqlakahi25fea3v"
boot_disk_size = 10

subnet_id = "ajc2gj********"
disk_size = 10
disk_type = "network-hdd"

nat_enabled = true
preemptible = true
ssh_user    = "ubuntu"
ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3Y06vlVKq2+osrm9Z7cD2y3Swfg/DD3zsfUjdPXsP0 future20-dev@homework"

labels = {
  environment = "dev"
  project     = "future-2-0"
}
