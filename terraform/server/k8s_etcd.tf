# Create Application server
resource "openstack_compute_instance_v2" "k8s_etcd" {
  count = "${var.count_k8s_etcd}"
  name = "k8s-etcd${count.index + 1}"
  image_name = "${var.image_name}"
  flavor_name = "${var.flavor_k8s_etcd}"
  key_pair = "${var.key_name}"
  metadata {
    host_groups = "k8s-etcd"
  }
  network {
    port = "${element(openstack_networking_port_v2.k8s_etcd_admin_port.*.id, count.index)}"
  }
  scheduler_hints {
      group = "${openstack_compute_servergroup_v2.k8s_etcd_admin_group.id}"
  }
  user_data = "${file("./cloud_init.sh")}"
}

# Create ports to admin_network
resource "openstack_networking_port_v2" "k8s_etcd_admin_port" {
  count = "${var.count_k8s_etcd}"
  name = "k8s-etcd-admin-port${count.index + 1}"
  network_id = "${var.id_network_admin}"
  admin_state_up = "true"
  security_group_ids = [ "${var.admin_sg}","${var.data_sg}","${var.etcd_sg}" ]
  fixed_ip {
    subnet_id = "${var.id_subnet_admin}"
  }
}
