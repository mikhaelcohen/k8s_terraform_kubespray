##### Variables network Admin #####
id_network_admin = "ee85e460-8243-4bfa-8cc2-935237e6fada"
id_subnet_admin = "6bb4a754-9148-4ea2-b3bc-664383d8040c"

# ##### Variables network Data #####
# id_network_data = "867ca29a-7ae8-4fa9-af43-9593b1e2fdef"
# id_subnet_data = "17ee42ca-1195-45fb-992c-db6753cd3b3b"

###### Variables security group ######
data_sg = "f481d2fb-a158-44cc-8788-20d4c6e0b60b"
admin_sg = "04f4f057-bbb7-4292-a705-b49cdc606243"
etcd_sg = "f15aee13-0d74-41f9-a668-43a3005111d3"
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
