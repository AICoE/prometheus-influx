PROJECT_NAME=${PROJECT:-"pkajaba"}
INFLUXDB_STORAGE=10Gi

.PHONY: all init deploy_influx deploy_storage_adapter deploy_prometheus deploy_node_exporter

create_project:
	oc new-project ${PROJECT}

deploy_influx:
	oc new-app -p STORAGE_SIZE="${INFLUXDB_STORAGE}" -l app=influxdb -f ./influxdb.yaml

deploy_storage_adapter:
	oc new-app -l app=prometheus-remote-storage-adapter -f ./prometheus-remote-storage-adapter.yaml

deploy_prometheus:
	oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:${PROJECT}:prometheus
	oc process -p NAMESPACE=${PROJECT} -f aiops-prometheus.yaml | oc apply -f -

deploy_grafana:
	bash ./setup-grafana.sh -n prometheus -p ${PROJECT}  # add -a for oauth, -e for node exporter

deploy_node_exporter:
	oc create -f node-exporter.yaml -n ${PROJECT}
	oc adm policy add-scc-to-user -z prometheus-node-exporter -n ${PROJECT} hostaccess
	oc annotate ns ${PROJECT} openshift.io/node-selector= --overwrite

init: create_project

all: init deploy_influx deploy_storage_adapter deploy_prometheus deploy_node_exporter
