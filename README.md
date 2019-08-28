# k8s_terraform_kubespray
K8s deployement on Openstack with  kubespray

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [k8s_terraform_kubespray](#k8sterraformkubespray)
	- [Infra Deployement](#infra-deployement)
		- [Network Deployement](#network-deployement)
		- [Servers Deployement](#servers-deployement)
	- [K8s Deployement](#k8s-deployement)
	- [K8s Usage](#k8s-usage)
	- [Tools](#tools)
		- [EFK](#efk)
		- [Prometheus](#prometheus)
		- [Grafana](#grafana)
	- [Next steps](#next-steps)

<!-- /TOC -->

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

## Tools

Go into `usage/tools`, you'll find directories :
* efk : Deploy an Elasticsearch Fluentd and Kibana stack
* monitoring/prometheus : Deploy a prometheus stack
* monitoring/grafana : Deploy a Grafana stack

### EFK

Go into `usage/tools/efk`

1. Create namespace `kube-logging`:
```
kubectl apply -f kube-logging.yml
```

2. Create Elasticsearch statefulset and service :
```
kubectl apply -f elasticsearch_statefulset.yaml
kubectl apply -f elasticsearch_svc.yaml
```

3. Create Fluentd demaonset :
```
kubectl apply -f fluentd.yml
```

4. Deploy Kibana webUI
```
kubectl apply -f kibana.yml
```

5. That's it ! After you can log in to http://kibana.k8smikhael.com and create index pattern with `logstah-*`


### Prometheus

Go into `usage/tools/monitoring/prometheus`

 1. Create `kube-monitoring` namespace
 ```
 kubectl apply -f kube-monitoring.yml
 ```

 2. Create Cluster role for prometheus user :
 ```
 kubectl apply -f clusterRole.yaml
 ```

 3. Create prometheus configmap :
 ```
 kubectl apply -f config-map.yaml
 ```

 4. Create prometheus deployment and service :
 ```
 kubectl apply -f prometheus-deployment.yaml
 kubectl apply -f prometheus-service.yaml
 ```

 5. Create prometheus deployment and service :
 ```
 kubectl apply -f prometheus-deployment.yaml
 kubectl apply -f prometheus-service.yaml
 ```

 6. That's it ! After you can log in to prometheus http://prometheus.k8smikhael.com and check status in `Status --> Targets`


### Grafana

Go into `usage/tools/monitoring/prometheus`. Grafana will be in the same namespace as prometheus `kube-monitoring`

 1. Create clusterRole for Grafana
 ```
 kubectl apply -f clusterRole.yaml
 ```

 2. Create secrets for Grafana :
 ```
 kubectl apply -f secret.yaml
 ```

 3. Create deployment and service for Grafana :
 ```
 kubectl apply -f deployement.yaml
 kubectl apply -f service.yaml
 ```

 4. That's it for the deployement. Grafana is available at http://grafana.k8smikhael.com/ with admin:admin

 5. Deployement of dashbord
 ```
 kubectl apply -f dashboard/
 ```

 6. Check the in prometheus and Kubernetes dashboard that you have all your node/master information

## Next steps
* Connect K8S to Openstack API for Volume --> Done
* Deploy EFK for logging within k8s --> Done
* Deploy Grafana and Prometheus for supervision --> Done
* Test traefik instead of nginx ingress
