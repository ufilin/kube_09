output "lb_external_ip" {
  description = "Внешний IP балансировщика — единая точка входа к API-серверу"
  value = one([
    for l in yandex_lb_network_load_balancer.k8s_api_lb.listener :
    one([for a in l.external_address_spec : a.address])
  ])
}

output "master_external_ips" {
  value = [for m in yandex_compute_instance.master : m.network_interface.0.nat_ip_address]
}

output "master_internal_ips" {
  value = [for m in yandex_compute_instance.master : m.network_interface.0.ip_address]
}

output "worker_external_ips" {
  value = [for w in yandex_compute_instance.worker : w.network_interface.0.nat_ip_address]
}

output "worker_internal_ips" {
  value = [for w in yandex_compute_instance.worker : w.network_interface.0.ip_address]
}

output "ansible_inventory" {
  description = "Готовый inventory.ini для Kubespray (HA control-plane + etcd на всех мастерах)"
  value = join("\n", concat(
    ["[all]"],
    [for i, m in yandex_compute_instance.master :
      "master${i + 1} ansible_host=${m.network_interface.0.nat_ip_address} ip=${m.network_interface.0.ip_address}"
    ],
    [for i, w in yandex_compute_instance.worker :
      "worker${i + 1} ansible_host=${w.network_interface.0.nat_ip_address} ip=${w.network_interface.0.ip_address}"
    ],
    [""],
    ["[kube_control_plane]"],
    [for i, m in yandex_compute_instance.master : "master${i + 1}"],
    [""],
    ["[etcd]"],
    [for i, m in yandex_compute_instance.master : "master${i + 1}"],
    [""],
    ["[kube_node]"],
    [for i, w in yandex_compute_instance.worker : "worker${i + 1}"],
    [""],
    ["[k8s_cluster:children]", "kube_control_plane", "kube_node"],
    [""],
    ["[all:vars]", "ansible_user=${var.ssh_user}"]
  ))
}
