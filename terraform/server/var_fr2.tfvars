##### Variables network Admin #####
id_network_admin = "d11a7425-51bb-41e4-9048-253ce0bc6a8c"
id_subnet_admin = "ab7eca79-d970-4b5d-a5b9-38bdb7fd40df"

# ##### Variables network Data #####
# id_network_data = "867ca29a-7ae8-4fa9-af43-9593b1e2fdef"
# id_subnet_data = "17ee42ca-1195-45fb-992c-db6753cd3b3b"

###### Variables security group ######
data_sg = "fca45bbd-ad7b-492c-8e79-ba1562fcce3c"
admin_sg = "5465d874-231c-457c-a2a5-3d8f0687cff9"
etcd_sg = "4a9d1025-d83a-43b2-91eb-f9dc152681d1"
###### Variables Instances ######
image_name = "CentOS 7.6"
key_name = "cwpn6480"

### Bastion ###
flavor_bastion="s1.cw.small-1"

### Master ###
flavor_k8s_master = "n2.cw.standard-4"
count_k8s_master ="3"

### Node ###
flavor_k8s_node = "n2.cw.standard-4"
count_k8s_node ="3"

### etcd ###
flavor_k8s_etcd = "n2.cw.standard-4"
count_k8s_etcd ="3"
