#!/bin/bash
shopt -s expand_aliases

set -euo pipefail
NAMESPACE="elastic-system"
MB_VERSION="7.16"
MB_MF="${1-metricbeat-kubernetes.yaml}"
SEC_KEY_REF="elasticsearch-sample-es-elastic-user"
echo "Printing to $MB_MF"
rm -f metricbeat*.yaml.* $MB_MF
wget https://raw.githubusercontent.com/elastic/beats/$MB_VERSION/deploy/kubernetes/metricbeat-kubernetes.yaml


if [ ! $(which yq) ]; then
    echo "please install yq"
    exit 1
fi
yq eval "del(select(di == 2).spec.template.spec.containers[0].env[3].value)" -P -i metricbeat-kubernetes.yaml
yq eval "select(di == 2).spec.template.spec.containers[0].env[3].valueFrom.secretKeyRef = {\"name\":\"$SEC_KEY_REF\",\"key\":\"elastic\"}" -P -i metricbeat-kubernetes.yaml
yq eval "select(di != 4) .metadata.namespace = \"$NAMESPACE\"" -i "$MB_MF"

