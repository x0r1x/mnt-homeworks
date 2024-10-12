resource "yandex_compute_instance" "vms-machine" {
  for_each = var.vms

  name        = each.value.name
  platform_id = each.value.platform_id
  
  resources {
    cores         = each.value.resources.core
    memory        = each.value.resources.memory
    core_fraction = each.value.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = each.value.boot_disk.type
      size     = each.value.boot_disk.size
    }
  }

  metadata = {
    ssh-keys = "${each.value.metadata.ssh-user}:${local.ssh_pub_key}"
  }

  scheduling_policy { 
    preemptible = each.value.scheduling_policy.preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.lab-subnet-a.id
    nat = each.value.network_interface.nat
  }
}