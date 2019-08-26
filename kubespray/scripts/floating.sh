#/bin/bash
lb_vip=$(neutron lb-vip-list | grep k8s-master-vip | awk -F "|" '{print $4}')
floating=$(neutron floatingip-list | grep $lb_vip | awk -F '|' '{print $4}' )
echo $floating
