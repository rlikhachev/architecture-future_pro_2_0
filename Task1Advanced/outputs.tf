output "vm_id" {
  description = "ID виртуальной машины."
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "Имя виртуальной машины."
  value       = module.vm.vm_name
}

output "vm_ip" {
  description = "Внутренний IP-адрес ВМ."
  value       = module.vm.vm_ip
}

output "vm_public_ip" {
  description = "Публичный IP-адрес ВМ (если NAT включён)."
  value       = module.vm.vm_public_ip
}

output "disk_id" {
  description = "ID подключаемого диска данных."
  value       = module.vm.disk_id
}
