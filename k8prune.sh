#!/bin/bash

# Delete all resources (pods, deployments, services) with a specific label
kubectl delete all -l app=your-app-name

# Delete any completed or failed jobs
kubectl delete job --field-selector=status.successful=1
kubectl delete job --field-selector=status.failed=1
#!/bin/bash

echo "Pruning unused resources..."

# Delete completed jobs
kubectl delete job --field-selector=status.successful=1

# Delete failed jobs
kubectl delete job --field-selector=status.failed=1

# Delete unused resources in the default namespace
kubectl delete all --all -n default

# Delete unused ReplicaSets
kubectl delete replicaset --all

echo "Pruning complete!"
