variable "yc_token" {
  description = "OAuth или IAM токен Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "ID облака"
  type        = string
}

variable "yc_folder_id" {
  description = "ID каталога (folder)"
  type        = string
}

variable "yc_zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу, который будет добавлен на все ноды"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_user" {
  description = "Имя пользователя, создаваемого на нодах через cloud-init"
  type        = string
  default     = "deb"
}

variable "image_family" {
  description = "Семейство образа для нод"
  type        = string
  default     = "ubuntu-2404-lts"
}

variable "worker_count" {
  description = "Количество worker-нод"
  type        = number
  default     = 4
}

variable "master_resources" {
  description = "Ресурсы для master-ноды (там же etcd)"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
}

variable "worker_resources" {
  description = "Ресурсы для worker-нод"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

variable "disk_size_gb" {
  description = "Размер диска на каждой ноде, ГБ"
  type        = number
  default     = 30
}

variable "preemptible" {
  description = "Использовать прерываемые (preemptible) ВМ для всех нод — дешевле, но Yandex Cloud может остановить такую ВМ не позже чем через 24 часа работы"
  type        = bool
  default     = true
}

variable "network_cidr" {
  description = "CIDR приватной подсети кластера"
  type        = string
  default     = "10.130.0.0/24"
}
