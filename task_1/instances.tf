data "yandex_compute_image" "node_image" {
  family = var.image_family
}

locals {
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_user       = var.ssh_user
    ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  })
}

resource "yandex_compute_instance" "master" {
  name        = "k8s-master"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  allow_stopping_for_update = true

  scheduling_policy {
    preemptible = var.preemptible
  }

  resources {
    cores         = var.master_resources.cores
    memory        = var.master_resources.memory
    core_fraction = var.master_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.node_image.id
      size     = var.disk_size_gb
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }

  metadata = {
    user-data = local.cloud_init
  }
}

resource "yandex_compute_instance" "worker" {
  count       = var.worker_count
  name        = "k8s-worker-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  allow_stopping_for_update = true

  scheduling_policy {
    preemptible = var.preemptible
  }

  resources {
    cores         = var.worker_resources.cores
    memory        = var.worker_resources.memory
    core_fraction = var.worker_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.node_image.id
      size     = var.disk_size_gb
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }

  metadata = {
    user-data = local.cloud_init
  }
}
