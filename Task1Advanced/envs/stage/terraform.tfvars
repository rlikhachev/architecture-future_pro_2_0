cloud_id  = "b1g*********"
folder_id = "b1g********"
zone_id   = "ru-central1-a"

vm_name     = "stage-app-01"
platform_id = "standard-v3"

core_count    = 4
core_fraction = 100
memory        = 8

image_id       = "f2e2apqlakahi25fea3v"
boot_disk_size = 15

subnet_id = "ajc2gj********"
disk_size = 30
disk_type = "network-ssd"

nat_enabled = true
preemptible = false
ssh_user    = "ubuntu"
ssh_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAa64igGE5+q4SYEFS1PgtQmEUNRZEn41p/mzIo0O+HZ future20-stage@homework"

labels = {
  environment = "stage"
  project     = "future-2-0"
}
