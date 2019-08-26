# Create Application server
resource "openstack_compute_instance_v2" "k8s_node" {
  count = "${var.count_k8s_node}"
  name = "k8s-node${count.index + 1}"
  image_name = "${var.image_name}"
  flavor_name = "${var.flavor_k8s_node}"
  key_pair = "${var.key_name}"
  metadata {
    host_groups = "k8s-node;k8s-cluster"
  }
  network {
    port = "${element(openstack_networking_port_v2.k8s_node_admin_port.*.id, count.index)}"
  }
  scheduler_hints {
      group = "${openstack_compute_servergroup_v2.k8s_node_admin_group.id}"
  }
  user_data = "${file("./cloud_init.sh")}"
}

# Create ports to admin_network
resource "openstack_networking_port_v2" "k8s_node_admin_port" {
  count = "${var.count_k8s_node}"
  name = "k8s-node-admin-port${count.index + 1}"
  network_id = "${var.id_network_admin}"
  admin_state_up = "true"
  security_group_ids = [ "${var.admin_sg}","${var.data_sg}" ]
  fixed_ip {
    subnet_id = "${var.id_subnet_admin}"
  }
}

# Create Pool
resource "openstack_lb_pool_v1" "k8s_node_pool" {
  name = "k8s-node-pool"
  protocol = "TCP"
  subnet_id = "${var.id_subnet_admin}"
  lb_method = "ROUND_ROBIN"
}

# Create VIP
resource "openstack_lb_vip_v1" "k8s_node_pool" {
  name = "k8s-node-vip"
  subnet_id = "${var.id_subnet_admin}"
  protocol = "TCP"
  port = 443
  pool_id = "${openstack_lb_pool_v1.k8s_node_pool.id}"
  admin_state_up = "true"
  floating_ip = "${openstack_compute_floatingip_v2.k8s_node_floatingip.address}"
}

# Create Pool Members
resource "openstack_lb_member_v1" "k8s_node_member" {
  count = "${var.count_k8s_node}"
  address = "${element(openstack_compute_instance_v2.k8s_node.*.access_ip_v4, count.index)}"
  pool_id = "${openstack_lb_pool_v1.k8s_node_pool.id}"
  port = 443
  admin_state_up = "true"
}

resource "openstack_compute_floatingip_v2" "k8s_node_floatingip" {
  pool = "public"
}
