#!/usr/bin/env bash

set -e

# Turn colors in this script off by setting the NO_COLOR variable in your
# environment to any value:
#
# $ NO_COLOR=1 test.sh
NO_COLOR=${NO_COLOR:-""}
if [ -z "$NO_COLOR" ]; then
  header=$'\e[1;33m'
  reset=$'\e[0m'
else
  header=''
  reset=''
fi


eventing_core_url=https://knative-nightly.storage.googleapis.com/eventing/latest/eventing-core.yaml
eventing_kafka_url=https://knative-nightly.storage.googleapis.com/eventing-kafka-broker/latest/eventing-kafka.yaml

function header_text {
  echo "$header$*$reset"
}

header_text "Knative Kafka Mesh - Installer"

header_text "Initializing Core APIs"
kubectl apply --filename $eventing_core_url

header_text "Waiting for Eventing Core to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-eventing

header_text "Initializing Eventing Kafka APIs"
kubectl apply --filename $eventing_kafka_url

header_text "Waiting for Eventing Kafka to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-eventing

header_text "Registering 'Kafka' as default Eventing Broker"
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: Kafka
      apiVersion: v1
      kind: ConfigMap
      name: kafka-broker-config
      namespace: knative-eventing
EOF

header_text "Registering 'Kafka' as default Eventing Channel"
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1beta1
      kind: KafkaChannel
      spec:
        numPartitions: 10
        replicationFactor: 3
EOF
