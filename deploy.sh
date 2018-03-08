#!/bin/bash -e

PROJECT_NAME=${PROJECT_NAME:-"aiops"}

# deploy prometheus
oc process -p NAMESPACE=$PROJECT_NAME -f  aiops-prometheus.yaml | oc apply -f -

# deploy prometheus-remote-storage
oc process -f prometheus-remote-storage-adapter.yaml | oc apply -f -

# deploy influxdb
oc process -f influxdb.yaml | oc apply -f -

# deploy node-exporter
oc create -f node-exporter.yaml -n $PROJECT_NAME
oc adm policy add-scc-to-user -z prometheus-node-exporter -n $PROJECT_NAME hostaccess
oc annotate ns $PROJECT_NAME openshift.io/node-selector= --overwrite
