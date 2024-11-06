output "vm" {

  value = [for k in yandex_compute_instance.vms-machine: { 
    name = k.name,
    id = k.id,
    fqdn = k.fqdn
    nat_ip = k.network_interface[0].nat_ip_address
  }]
}
