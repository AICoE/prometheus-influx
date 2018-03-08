
oc create -f node-exporter.yaml -n kube-system
oc adm policy add-scc-to-user -z prometheus-node-exporter -n kube-system hostaccess
oc annotate ns kube-system openshift.io/node-selector= --overwrite
