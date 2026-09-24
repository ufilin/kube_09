resource "yandex_lb_target_group" "k8s_master_tg" {
  name      = "k8s-master-tg"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.master
    content {
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "k8s_api_lb" {
  name = "k8s-api-lb"
  type = "external"

  listener {
    name = "k8s-api"
    port = 6443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_master_tg.id

    healthcheck {
      name = "k8s-api-health"
      tcp_options {
        port = 6443
      }
      interval             = 5
      timeout               = 2
      unhealthy_threshold    = 2
      healthy_threshold      = 2
    }
  }
}
