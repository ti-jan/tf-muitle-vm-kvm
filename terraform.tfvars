vms = [
  {
    name           = "debian"
    cpu            = 2
    memory         = 2048
    disksize       = 32
    storage_pool   = "default"
    os_image_name  = "debian_image.qcow2"
    os_datas_name  = "debian_datas.qcow2"
    network_name   = "tfnet"
    user_data      = "debian-cloud-init.yml"
    network_config = "debian-network-config.yml"
    os_image_url   = "/home/gean/kvm/templates/debian-12-generic-amd64.qcow2"
  },
  {
    name           = "oracle"
    cpu            = 2
    memory         = 2048
    disksize       = 64
    storage_pool   = "default"
    os_image_name  = "oracle_image.qcow2"
    os_datas_name  = "oracle_datas.qcow2"
    network_name   = "tfnet"
    user_data      = "ol9-cloud-init.yml"
    network_config = "ol9-network-config.yml"
    os_image_url   = "/home/gean/kvm/templates/OL9U3_x86_64-kvm-b220.qcow2"
  },
  {
    name           = "ubuntu"
    cpu            = 2
    memory         = 2048
    disksize       = 32
    storage_pool   = "default"
    os_image_name  = "ubuntu_image.qcow2"
    os_datas_name  = "ubuntu_datas.qcow2"
    network_name   = "tfnet"
    user_data      = "ubuntu-cloud-init.yml"
    network_config = "ubuntu-network-config.yml"
    os_image_url   = "/home/gean/kvm/templates/ubuntu-22.04-server-cloudimg-amd64.img"
  },
]
