# k8s_terraform_kubespray
K8s deployement on Openstack with  kubespray

## Infra Deployement

### Network Deployement
Source Openstack environment with credentials.

Deploy network :

in `k8s_terraform_kubespray/terraform/network`, deploy network, router and security group :
```
terraform plan
```
then
```
terraform apply
```

### Servers Deployement
Source Openstack environment with credentials.

Deploy servers  :

in `k8s_terraform_kubespray/terraform/server`, deploy network, router and security group :
```
terraform plan -var-file=var_fr2.tfvars
```
then
```
terraform apply -var-file=var_fr2.tfvars
```

## K8s Deployement

Set into your .ssh/config, the ssh config with Floating IP

Go into `k8s_terraform_kubespray/kubespray/` :
```
ansible-playbook --flush-cache -i inventory/mycluster/ --become --become-user=root cluster.yml
```

## K8s Usage


Go into `k8s_terraform_kubespray/templates/` :
```
./setup_k8s.sh
```

It will display you the floating IP and the Token to use to connect to the Dashboard


Next steps :
* Connect K8S to Openstack API for Volume
* Deploy EFK for logging within k8s
* Deploy Grafana and Prometheus for supervision
* Test traefik instead of nginx ingress 
