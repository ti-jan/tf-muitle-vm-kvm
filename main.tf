# Configuração do provider Terraform para o uso de libvirt para provisionamento de VMs
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

# Definição do provider libvirt com a URI do sistema qemu, que é um hypervisor local
provider "libvirt" {
  uri = "qemu:///system"
}

# Declaração de variável para armazenar a configuração das VMs
variable "vms" {
  description = "A list of virtual machines"
  type = list(object({
    name           = string
    cpu            = number
    memory         = number
    disksize       = number
    storage_pool   = string
    os_image_name  = string
    os_datas_name  = string
    network_name   = string
    user_data      = string
    network_config = string
    os_image_url   = string
  }))
  default = []
}

# Configuração de rede virtual no libvirt com NAT, sem DHCP, indicando mais controle sobre a conectividade
resource "libvirt_network" "tfnet" {
  name      = "tfnet"
  mode      = "nat"
  addresses = ["10.1.2.0/24"]
  autostart = true
  dhcp {
    enabled = false
  }
}

# Criação de volumes para as imagens do sistema operacional de cada VM, usando contagem baseada no número de VMs
resource "libvirt_volume" "os_image" {
  for_each = { for vm in var.vms : vm.name => vm }

  name   = each.value.os_image_name
  pool   = each.value.storage_pool
  source = each.value.os_image_url
  format = "qcow2"
}

# Criação de volumes para os discos de dados de cada VM
resource "libvirt_volume" "os_volume" {
  for_each = { for vm in var.vms : vm.name => vm }

  name           = each.value.os_datas_name
  base_volume_id = libvirt_volume.os_image[each.key].id
  pool           = each.value.storage_pool
  size           = each.value.disksize * 1024 * 1024 * 1024 // GB to bytes
}

# Geração de configurações de usuário e rede a partir de templates de arquivos de cloud-init
data "template_file" "user_data" {
  for_each = { for vm in var.vms : vm.name => vm }

  template = file("${path.module}/${each.value.user_data}")
}

data "template_file" "network_config" {
  for_each = { for vm in var.vms : vm.name => vm }

  template = file("${path.module}/${each.value.network_config}")
}

# Criação de discos de cloud-init para as VMs, contendo as configurações de usuário e rede
resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = { for vm in var.vms : vm.name => vm }

  name           = "${each.key}_cloudinit.iso"
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
  pool           = each.value.storage_pool
}

# Definição das domínios das VMs, configurando recursos como memória, CPU e interfaces de rede
resource "libvirt_domain" "domain" {
  for_each = { for vm in var.vms : vm.name => vm }

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.cpu

  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_name = each.value.network_name
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.os_volume[each.key].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

