resource "yandex_vpc_network" "lab-net" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "lab-subnet-a" {
  v4_cidr_blocks = var.default_cidr
  zone           = var.default_zone
  network_id     = yandex_vpc_network.lab-net.id
}

# data "yandex_compute_image" "container-optimized-image" {
#   family = "container-optimized-image"
# }

data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2004-lts"
}

# # Cчитываем данные об образе ОС
# data "yandex_compute_image" "centos-7" {
#   family = "centos-stream-9-oslogin"
# }
