output "vm_id" {
  description = "ID виртуальной машины."
  value       = yandex_compute_instance.vm.id
}

output "vm_name" {
  description = "Имя виртуальной машины."
  value       = yandex_compute_instance.vm.name
}

output "vm_ip" {
  description = "Внутренний (private) IP-адрес ВМ."
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "vm_public_ip" {
  description = "Публичный (NAT) IP-адрес ВМ; пустая строка, если NAT отключён."
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "vm_fqdn" {
  description = "FQDN виртуальной машины."
  value       = yandex_compute_instance.vm.fqdn
}

output "disk_id" {
  description = "ID подключаемого диска данных."
  value       = yandex_compute_disk.data.id
}
