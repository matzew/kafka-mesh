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

function header_text {
  echo "$header$*$reset"
}

header_text "Knative Eventing Development Tools"

header_text "Initializing 'In Memory Channel' APIs"
kubectl apply --filename https://knative-nightly.storage.googleapis.com/eventing/latest/in-memory-channel.yaml

header_text "Waiting for 'In Memory Channel' to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-eventing

header_text "Info 'Channel based Broker 'usage:"
header_text "apiVersion: messaging.knative.dev/v1"
header_text "kind: InMemoryChannel"
header_text "metadata:"
header_text "  name: testchannel"


header_text "Initializing 'Channel based Broker' APIs"
kubectl apply --filename https://knative-nightly.storage.googleapis.com/eventing/latest/mt-channel-broker.yaml

header_text "Waiting for 'Channel based Broker' to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-eventing

header_text "Info 'Channel based Broker 'usage:"
header_text "apiVersion: eventing.knative.dev/v1"
header_text "kind: Broker"
header_text "metadata:"
header_text "  annotations:"
header_text "    eventing.knative.dev/broker.class: MTChannelBasedBroker"
header_text "  namespace: default"
header_text "  name: my-channel-based-broker"
header_text "spec:"
header_text "  # Configuration specific to this broker."
header_text "  config:"
header_text "    apiVersion: v1"
header_text "    kind: ConfigMap"
header_text "    name: config-br-default-channel"
header_text "    namespace: knative-eventing"
