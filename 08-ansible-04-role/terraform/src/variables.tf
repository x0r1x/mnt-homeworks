###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.1.0.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "lab-network"
  description = "VPC network&subnet name"
}

###common vars
variable "vms" {
  type = map(object({
    name        = string
    platform_id = string
    resources   = object({
      core = number
      memory = number
      core_fraction = number 
    })
    boot_disk = object({
      type = string
      size = number
    })
    scheduling_policy = object({
      preemptible = bool
    })
    network_interface = object({
      nat = bool
    })
    metadata = object({
      serial-port-enable = number
      ssh-user = string
    })
  }))
  default = {
      "clickhouse" = {
        name = "clickhouse-01"
        platform_id = "standard-v1"
        public_ip = true
        resources = {
          core=2
          memory=2
          core_fraction=20
        }
        boot_disk = {
          type = "network-hdd"
          size = 10
        }
        scheduling_policy = {
          preemptible = true
        }
        network_interface = {
          nat = true
        }
        metadata = {
          serial-port-enable = 1
          ssh-user  = "ubuntu"
        }
      }
      "lighthouse" = {
        name = "lighthouse-01"
        platform_id = "standard-v1"
        public_ip = true
        resources = {
          core=2
          memory=2
          core_fraction=5
        }
        boot_disk = {
          type = "network-hdd"
          size = 5
        }
        scheduling_policy = {
          preemptible = true
        }
        network_interface = {
          nat = true
        }
        metadata = {
          serial-port-enable = 1
          ssh-user  = "ubuntu"
        }
      }
  }
}