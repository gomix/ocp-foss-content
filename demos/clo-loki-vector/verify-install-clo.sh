#!/usr/bin/bash
#
# ns exist
echo "namespace"
oc get ns openshift-logging
echo "operatorgroup"
oc get operatorgroup cluster-logging -n openshift-logging
echo "subcription"
oc get sub cluster-logging -n openshift-logging

