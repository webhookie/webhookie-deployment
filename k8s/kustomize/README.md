# Deploy webhookie using k8s
This README helps get up and running webhookie on k8s cluster.*tested on minikube and EKS*

# Dependencies
- Required tools and applications:
  - `jq` v1.6 or above
  - `kubectl` v1.26 or above
  - `Kustomize` v4.5.x or above
  - `helm` v3.11.x or above
  - `minikube` v1.30.x or above ( if running locally)
  - `eks` v0.114.0 ( if running on EKS cluster)

### NOTE: 
  - eks clusters created by higher versions is not supported yet
  - `kubectl` must be configured with a `minikube` or 'EKS` cluster

# Get Started
- To get started using `bash` use `./webhookie.sh`

To get full understanding of the options to customize deployment and branding use `--help`

To understand more about `webhookie` architecture and concepts please go to [webhookie docs](https://webhookie.com/docs)

# Run locally with minikube
  * [Installation guide](https://minikube.sigs.k8s.io/docs/start/)
  * Run `minikube`
    * example run command: ```minikube --memory 8192 --cpus 4 start```
    * make sure you have enough resources allocated to your docker


### Examples:
- #### Example 1: Runs on M1 mac adding logging capability
```#!/bin/sh
./webhookie.s --with-logging
```

- #### Example 2: Runs adding monitoring and subscription sample capability
```#!/bin/sh
./webhookie.sh --with-logging --with-demo
```

- #### Example 3: Runs with setting the mail color
```#!/bin/sh
./webhookie.sh --branding-color=#030303
```

- #### Example 4: Runs with whitelabel
```#!/bin/sh
./webhookie.sh --branding=./my-branding
```

- #### Example 4: Runs with custom auth provider
```#!/bin/sh
./webhookie.sh --auth=./auth.env
```
