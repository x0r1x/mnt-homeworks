resource "yandex_vpc_network" "lab-net" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "lab-subnet-a" {
  v4_cidr_blocks = var.default_cidr
  zone           = var.default_zone
  network_id     = yandex_vpc_network.lab-net.id
}

#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2004-lts"
}
