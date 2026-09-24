resource "yandex_vpc_network" "k8s_network" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = "k8s-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = [var.network_cidr]
}
