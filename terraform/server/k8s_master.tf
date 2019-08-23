# Create Application server
resource "openstack_compute_instance_v2" "k8s_master" {
  count = "${var.count_k8s_master}"
  name = "k8s-master${count.index + 1}"
  image_name = "${var.image_name}"
  flavor_name = "${var.flavor_k8s_master}"
  key_pair = "${var.key_name}"
  metadata {
    host_groups = "k8s-master;k8s-cluster"
  }
  network {
    port = "${element(openstack_networking_port_v2.k8s_master_admin_port.*.id, count.index)}"
  }
  scheduler_hints {
      group = "${openstack_compute_servergroup_v2.k8s_master_admin_group.id}"
  }
  user_data = "${file("./cloud_init.sh")}"
}

# Create ports to admin_network
resource "openstack_networking_port_v2" "k8s_master_admin_port" {
  count = "${var.count_k8s_master}"
  name = "k8s-master-admin-port${count.index + 1}"
  network_id = "${var.id_network_admin}"
  admin_state_up = "true"
  security_group_ids = [ "${var.admin_sg}","${var.data_sg}" ]
  fixed_ip {
    subnet_id = "${var.id_subnet_admin}"
  }
}

# Create Pool
resource "openstack_lb_pool_v1" "k8s_master_pool" {
  name = "k8s-master-pool"
  protocol = "TCP"
  subnet_id = "${var.id_subnet_admin}"
  lb_method = "ROUND_ROBIN"
}

# Create VIP
resource "openstack_lb_vip_v1" "k8s_master_vip" {
  name = "k8s-master-vip"
  subnet_id = "${var.id_subnet_admin}"
  protocol = "TCP"
  port = 443
  pool_id = "${openstack_lb_pool_v1.k8s_master_pool.id}"
  admin_state_up = "true"
  floating_ip = "${openstack_compute_floatingip_v2.k8s_master_floatingip.address}"
}

# Create Pool Members
resource "openstack_lb_member_v1" "k8s_master_member" {
  count = "${var.count_k8s_master}"
  address = "${element(openstack_compute_instance_v2.k8s_master.*.access_ip_v4, count.index)}"
  pool_id = "${openstack_lb_pool_v1.k8s_master_pool.id}"
  port = 6443
  admin_state_up = "true"
}

resource "openstack_compute_floatingip_v2" "k8s_master_floatingip" {
  pool = "public"
}
