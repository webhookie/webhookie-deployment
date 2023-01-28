## Install operator
```bash
k apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
```

## Deploy rabbitmq replica set
```bash
k create ns webhookie-rabbitmq
kustomize build . | k apply --namespace webhookie-rabbitmq -f -
```

Get the service details:
```bash
k get rabbitmqcluster webhookie-rabbitmq -o json | jq -r '.status.defaultUser.secretReference.name'
k get rabbitmqcluster webhookie-rabbitmq -o json | jq -r '.status.defaultUser.secretReference.namespace'
```

## Port forward:
```bash
k port-forward -n webhookie-rabbitmq service/webhookie-rabbitmq 15672
```

## Links
- [Installing RabbitMQ Cluster Operator in a Kubernetes Cluster](https://www.rabbitmq.com/kubernetes/operator/install-operator.html)
- [Using RabbitMQ Cluster Kubernetes Operator](https://www.rabbitmq.com/kubernetes/operator/using-operator.html#service-availability)
- [Github abbitmq/diy-kubernetes-examples](https://github.com/rabbitmq/diy-kubernetes-examples/tree/master/minikube)
- [Examples](https://github.com/rabbitmq/cluster-operator/tree/main/docs/examples)

