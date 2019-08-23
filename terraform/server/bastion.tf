# Create Application server
resource "openstack_compute_instance_v2" "bastion_ssh" {
  name = "bastion-ssh"
  image_name = "${var.image_name}"
  flavor_name = "${var.flavor_bastion}"
  key_pair = "${var.key_name}"
  metadata {
    host_groups = "bastion-ssh"
  }
  network {
    port = "${openstack_networking_port_v2.bastion_ssh_port.id}"
  }
  user_data = "${file("./cloud_init.sh")}"
}

# Create ports to admin_network
resource "openstack_networking_port_v2" "bastion_ssh_port" {
  name = "bastion-ssh-port"
  network_id = "${var.id_network_admin}"
  admin_state_up = "true"
  security_group_ids = [ "${var.admin_sg}" ]
  fixed_ip {
    subnet_id = "${var.id_subnet_admin}"
  }
}

resource "openstack_compute_floatingip_v2" "bastion_ssh_floatingip" {
  pool = "public"
}

resource "openstack_networking_floatingip_associate_v2" "bastion_ssh_floatingip_association" {
  floating_ip = "${openstack_compute_floatingip_v2.bastion_ssh_floatingip.address}"
  port_id = "${openstack_networking_port_v2.bastion_ssh_port.id}"
}
