output "master_external_ip" {
  value = yandex_compute_instance.master.network_interface.0.nat_ip_address
}

output "master_internal_ip" {
  value = yandex_compute_instance.master.network_interface.0.ip_address
}

output "worker_external_ips" {
  value = [for w in yandex_compute_instance.worker : w.network_interface.0.nat_ip_address]
}

output "worker_internal_ips" {
  value = [for w in yandex_compute_instance.worker : w.network_interface.0.ip_address]
}

output "ansible_inventory" {
  description = "Готовый inventory.ini для Kubespray — можно перенаправить в файл"
  value = join("\n", concat(
    ["[all]"],
    ["master ansible_host=${yandex_compute_instance.master.network_interface.0.nat_ip_address} ip=${yandex_compute_instance.master.network_interface.0.ip_address}"],
    [for i, w in yandex_compute_instance.worker :
      "worker${i + 1} ansible_host=${w.network_interface.0.nat_ip_address} ip=${w.network_interface.0.ip_address}"
    ],
    [""],
    ["[kube_control_plane]", "master"],
    [""],
    ["[etcd]", "master"],
    [""],
    ["[kube_node]"],
    [for i, w in yandex_compute_instance.worker : "worker${i + 1}"],
    [""],
    ["[k8s_cluster:children]", "kube_control_plane", "kube_node"]
  ))
}
