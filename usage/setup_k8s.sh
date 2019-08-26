#!/bin/sh

HOME_KUBESPRAY=/Users/mikhael/Documents/1_GIT/CW/formation/k8s_terraform_kubespray/kubespray
TARGET=/Users/mikhael/Documents/1_GIT/CW/formation/k8s_terraform_kubespray/templates

lb_vip_node=$(neutron lb-vip-list | grep k8s-node-vip | awk -F "|" '{print $4}'| sed 's/ //g')
floating_node=$(neutron floatingip-list | grep $lb_vip_node | awk -F '|' '{print $4}' | sed 's/ //g')

lb_vip=$(neutron lb-vip-list | grep k8s-master-vip | awk -F "|" '{print $4}'| sed 's/ //g')
floating_api=$(neutron floatingip-list | grep $lb_vip | awk -F '|' '{print $4}' | sed 's/ //g')

echo "Floating Ingress : ${floating_node}"
echo "Floating API : ${floating_api}"
echo "URL Dashboard : https://${floating_api}:443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login"

sed  "s/$lb_vip/$floating_api/g" ${HOME_KUBESPRAY}/inventory/mycluster/artifacts/admin.conf > ${TARGET}/admin-k8s.conf

export KUBECONFIG=${TARGET}/admin-k8s.conf

echo "Creating Admin user for Dashboard"
kubectl apply -f ${TARGET}/admin-user.yml --validate=false > /dev/null 2>&1

token=$(kubectl describe secret mikhael-user-token -n kube-system | grep "token:" | awk -F " " '{print $2}')

echo "Token is : $token"
