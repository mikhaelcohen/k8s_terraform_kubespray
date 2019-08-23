## Admin Network
resource "openstack_networking_network_v2" "network_admin" {
  name           = "network_admin"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_admin" {
  name       = "subnet_admin"
  network_id = "${openstack_networking_network_v2.network_admin.id}"
  cidr       = "192.168.100.0/24"
  ip_version = 4
}

# Router internet sur admin
resource "openstack_networking_router_v2" "internet_router" {
  name = "internet_router"
  admin_state_up      = true
  enable_snat         = true
  external_network_id = "b5dd7532-1533-4b9c-8bf9-e66631a9be1d"
}

resource "openstack_networking_router_interface_v2" "internet_router_internet" {
  router_id = "${openstack_networking_router_v2.internet_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_admin.id}"
}



# ## Data Network
# resource "openstack_networking_network_v2" "network_data" {
#   name           = "network_data"
#   admin_state_up = "true"
# }
#
# resource "openstack_networking_subnet_v2" "subnet_data" {
#   name       = "subnet_data"
#   network_id = "${openstack_networking_network_v2.network_data.id}"
#   cidr       = "192.168.200.0/24"
#   ip_version = 4
# }
