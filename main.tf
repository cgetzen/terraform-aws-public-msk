data "aws_msk_cluster" "cluster" {
  cluster_name = var.cluster_name
}

locals {
  addrs = split(",", data.aws_msk_cluster.cluster.bootstrap_brokers_tls)
  hosts = [for x in local.addrs : split(":", x)[0]]
}

data "dns_a_record_set" "brokers" {
  count = data.aws_msk_cluster.cluster.number_of_broker_nodes
  host  = local.hosts[count.index]
}

data "aws_network_interfaces" "network_interfaces" {
  count = data.aws_msk_cluster.cluster.number_of_broker_nodes
  filter {
    name   = "private-ip-address"
    values = data.dns_a_record_set.brokers.*.addrs[count.index]
  }
}

resource "aws_eip" "eips" {
  count                     = data.aws_msk_cluster.cluster.number_of_broker_nodes
  network_interface         = tolist(data.aws_network_interfaces.network_interfaces[count.index].ids)[0]
  associate_with_private_ip = data.dns_a_record_set.brokers.*.addrs[count.index][0]
  tags                      = merge(var.tags, { ID = count.index })
}
