data "aws_msk_cluster" "cluster" {
  cluster_name = var.cluster_name
}

locals {
  addrs = split(",", data.aws_msk_cluster.cluster.bootstrap_brokers_tls)
  hosts = toset([for x in local.addrs : split(":", x)[0]])
}

data "dns_a_record_set" "brokers" {
  for_each = local.hosts
  host     = each.value
}

data "aws_network_interfaces" "network_interfaces" {
  for_each = data.dns_a_record_set.brokers
  filter {
    name   = "private-ip-address"
    values = each.value.addrs
  }
}

resource "aws_eip" "eips" {
  for_each                  = data.dns_a_record_set.brokers
  network_interface         = tolist(data.aws_network_interfaces.network_interfaces[each.key].ids)[0]
  associate_with_private_ip = each.value.addrs[0]
  tags                      = merge(var.tags, data.aws_msk_cluster.cluster.tags, { host = each.key })
}

locals {
  host_mapping = [for key, val in aws_eip.eips : format("%s   %s\n", val.public_ip, key)]
  content      = join("", local.host_mapping)
}

resource "local_file" "file" {
  count           = var.create_host_file ? 1 : 0
  content         = local.content
  filename        = "${path.root}/hosts"
  file_permission = "0644"
}
