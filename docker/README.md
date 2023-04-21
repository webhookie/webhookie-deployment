# docker-compose
This README helps get up and running webhookie on docker-compose

# Command Line Arguments

`$ ./ruu` or `./run.ps1`
This  brings all services with default values

## default values
- *size: medium* 
  - Available Values:
    - small
    - medium
    - large
    - x-large
  - More about the values:
    ```
    SMALL_MS_MEM=128
    SMALL_MX_MEM=512
    SMALL_CPU_RES=0.25
    SMALL_CPU_LIMIT=0.5

    MEDIUM_MS_MEM=512
    MEDIUM_MX_MEM=1024
    MEDIUM_CPU_RES=0.5
    MEDIUM_CPU_LIMIT=1

    LARGE_MS_MEM=1024
    LARGE_MX_MEM=2048
    LARGE_CPU_RES=1.5
    LARGE_CPU_LIMIT=2

    X_LARGE_MS_MEM=2048
    X_LARGE_MX_MEM=4096
    X_LARGE_CPU_RES=2.5
    X_LARGE_CPU_LIMIT=3
    ```
- *version: latest*
  - Available values:
    - beta
    - latest
- *command: up* 
  - Available Values:
    - up
    - config
    - down
- *auth_provider: keycloak*

# Available Arguments:
- --beta
  - runs beta version of all webhookie-services
- --help
  - shows this page
- --size=[small/medium/large/x-large]
  - sets resource reservations and limits for the services
- --dry-run
  - shows full compose file with the current values
- --config
  - alias for --dry-run
- --down
  - brings services down
- --up
  - brings services up
- --arm
  - uses arm keycloak image for M1 Macs
- --auth0
  - removes keycloak from the stack and sets auth0 as auth provider 
    - NOTE: consider having auth0.env file in the same folder as keycloak.env
- --with-logging
  - Adds ELK(elasticsearch, kibana, filebeat)
- --with-monitoring
  - Adds Monitoring(Prometheus and Grafana) 
- --with-sample
  - Adds Sample subscription application
- --no-mongo
  - removes MongoDB container from the deployment
    - NOTE: consider updating env variables
- --no-rabbit
  - Adds RabbitMQ container from the deployment
    - NOTE: consider updating env variables"
- --no-portal
  - removes webhookie-portal from the deployment
- --no-registry
  - removes Eureka from the deployment
- --branding
  - points to your own branding folder if you want to re-brand webhookie
- --branding-color
  - updates webhookie portal with the given color as the main color

### Example 1: Runs on M1 mac adding logging capability

```#!/bin/sh

./run --arm --with-logging
```

### Example 2: Runs adding monitoring and subscription sample capability

```#!/bin/sh

./run --with-logging --with-sample
```

### Example 3: Runs with setting the mail color

```#!/bin/sh

./run --branding-color=#030303
```

### Example 4: Runs with whitelabel

```#!/bin/sh

./run --branding=./my-branding
```
