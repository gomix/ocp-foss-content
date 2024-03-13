oc delete subscription  cluster-logging -n openshift-logging
oc delete operatorgroup cluster-logging -n openshift-logging
oc delete namespace cluster-logging 
oc delete subscription elasticsearch-operator -n openshift-operators-redhat
