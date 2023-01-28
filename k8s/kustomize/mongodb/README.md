## Install CRD
```bash
kustomize build https://github.com/mongodb/mongodb-kubernetes-operator.git/config/crd | k apply -f -
```
or 
```bash
k apply -f config/crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml
```

Verify that the Custom Resource Definitions installed successfully:
```bash
k get crd/mongodbcommunity.mongodbcommunity.mongodb.com
```

Optional: Create ns:
```bash
k create ns webhookie-mongodb
```

## Install RBAC
```bash
kustomize build https://github.com/mongodb/mongodb-kubernetes-operator.git/config/rbac | k apply --namespace webhookie-mongodb -f -
```

or

```bash
k apply -k config/rbac/ --namespace webhookie-mongodb
```

Verify that the resources have been created:

```bash
k get role mongodb-kubernetes-operator --namespace webhookie-mongodb
k get rolebinding mongodb-kubernetes-operator --namespace webhookie-mongodb
k get serviceaccount mongodb-kubernetes-operator --namespace webhookie-mongodb
```

## Install Operator
```bash
kustomize build https://github.com/mongodb/mongodb-kubernetes-operator.git/config/manager | k apply --namespace webhookie-mongodb -f -
```
or
```bash
k create -f config/manager/manager.yaml --namespace webhookie-mongodb
```

## Deploy mongodb replica set
```bash
kustomize build . | k apply --namespace webhookie-mongodb -f -
```

Get the connection string:
```bash
k get secret webhookie-mongodb-admin-webhookie-user -n webhookie-mongodb -o json | jq -r '.data | with_entries(.value |= @base64d)'
```

## Port forward:
```bash
k port-forward -n webhookie-mongodb service/webhookie-mongo-express 8081
```

## Links
- [Kustomize Cheat sheet](https://itnext.io/kubernetes-kustomize-cheat-sheet-8e2d31b74d8f)
- [Operator Github](https://github.com/mongodb/mongodb-kubernetes-operator)

