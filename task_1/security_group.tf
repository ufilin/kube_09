resource "yandex_vpc_security_group" "k8s_sg" {
  name       = "k8s-sg"
  network_id = yandex_vpc_network.k8s_network.id

  # Весь трафик между нодами кластера внутри приватной подсети —
  # закрывает разом kubelet(10250), etcd(2379-2380), scheduler/controller-manager,
  # BGP(179) и IPIP для Calico, kube-proxy и т.д.
  ingress {
    protocol       = "ANY"
    description    = "Internal traffic between cluster nodes"
    v4_cidr_blocks = [var.network_cidr]
  }

  # SSH снаружи (для Ansible/Kubespray и ручного доступа)
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API снаружи (kubectl, kubeadm/kubespray join, kubeconfig)
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort-сервисы снаружи, если понадобятся
  ingress {
    protocol       = "TCP"
    description    = "NodePort services"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP для диагностики (ping)
  ingress {
    protocol       = "ICMP"
    description    = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
