terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.cloud_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}


resource "yandex_compute_instance" "web-1" {
  name = "web-1"
  hostname = "web-1"
  allow_stopping_for_update = true
	platform_id = "standard-v1"
  zone      = "ru-central1-a"
    metadata = {
    user-data = "${file("./meta.yml")}"
  }

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8hnnsnfn3v88bk0k1o"
      size = var.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-1.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address         = "10.1.0.10"
  }

}


resource "yandex_compute_instance" "web-2" {
  name = "web-2"
  hostname = "web-2"
  allow_stopping_for_update = true
	platform_id = "standard-v1"
  zone      = "ru-central1-b"
    metadata = {
    user-data = "${file("./meta.yml")}"
  }

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8hnnsnfn3v88bk0k1o"
      size = var.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-2.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address         = "10.2.0.10"
  }

}

resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  hostname = "zabbix"
  allow_stopping_for_update = true
	platform_id = "standard-v3"
  zone      = "ru-central1-d"
    metadata = {
    user-data = "${file("./meta.yml")}"
  }

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8hnnsnfn3v88bk0k1o"
      size = var.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.zabbix-sg.id]
    ip_address         = "10.4.0.20"
    nat                = true

  }

}


resource "yandex_compute_instance" "elastic" {
  name     = "elastic"
  hostname = "elastic"
  allow_stopping_for_update = true
	platform_id = "standard-v3"
  zone      = "ru-central1-d"
    metadata = {
    user-data = "${file("./meta.yml")}"
  }

  resources {
    cores  = 4
    memory = 8
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8hnnsnfn3v88bk0k1o"
      size = var.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet-3.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.elastic-sg.id]
    ip_address         = "10.3.0.100"
  }

}



resource "yandex_compute_instance" "kibana" {
  name     = "kibana"
  hostname = "kibana"
   allow_stopping_for_update = true
	platform_id = "standard-v3"
  zone      = "ru-central1-d"
    metadata = {
    user-data = "${file("./meta.yml")}"
  }

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8hnnsnfn3v88bk0k1o"
      size = var.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.kibana-sg.id]
    ip_address         = "10.4.0.100"
    nat                = true

  }

}

resource "yandex_compute_instance" "jump" {
  name     = "jump"
  hostname = "jump"
   allow_stopping_for_update = true
	platform_id = "standard-v3"
  zone      = "ru-central1-d"
    metadata = {
    user-data = "${file("./meta.yml")}"
  }

  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8hnnsnfn3v88bk0k1o"
      size = var.size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.jump-sg.id]
    ip_address         = "10.4.0.10"
    nat                = true
  }

}

// outputs
output "zabbix_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "kibana_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
output "jump" {
  value = yandex_compute_instance.jump.network_interface.0.nat_ip_address
}
