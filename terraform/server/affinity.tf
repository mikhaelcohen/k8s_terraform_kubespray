resource "openstack_compute_servergroup_v2" "k8s_master_admin_group" {
	name = "k8s_master_admin_group"
	policies = ["anti-affinity"]
}

resource "openstack_compute_servergroup_v2" "k8s_node_admin_group" {
	name = "k8s_node_admin_group"
	policies = ["anti-affinity"]
}

resource "openstack_compute_servergroup_v2" "k8s_etcd_admin_group" {
	name = "k8s_etcd_admin_group"
	policies = ["anti-affinity"]
}
