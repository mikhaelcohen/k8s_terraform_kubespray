## Admin Sec Group
resource "openstack_networking_secgroup_v2" "admin_sg" {
  name        = "admin_sg"
  description = "Admin security group"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_admin_sg" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.admin_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_admin_sg1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.admin_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_admin_sg2" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.admin_sg.id}"
}


## Data Sec Group
resource "openstack_networking_secgroup_v2" "data_sg" {
  name        = "data_sg"
  description = "Data security group"
}

resource "openstack_networking_secgroup_rule_v2" "https_data_sg" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "http_data_sg1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8090
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "http_data_sg2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10256
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6783
  port_range_max    = 6783
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg6" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 4149
  port_range_max    = 4149
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg7" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9099
  port_range_max    = 9099
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_data_sg8" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8443
  port_range_max    = 8443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "calico_data_sg1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 179
  port_range_max    = 179
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "calico_data_sg2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5473
  port_range_max    = 5473
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "calico_data_sg3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 4789
  port_range_max    = 4789
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_data_sg1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_data_sg2" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "flannel_data_sg1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8285
  port_range_max    = 8285
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "flannel_data_sg2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.data_sg.id}"
}

## ETCD Sec Group
resource "openstack_networking_secgroup_v2" "etcd_sg" {
  name        = "etcd_sg"
  description = "ETCD security group"
}

resource "openstack_networking_secgroup_rule_v2" "port_etcd_sg" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.etcd_sg.id}"
}
