## Step 0
* Run minikube
  * [Installation guide](https://minikube.sigs.k8s.io/docs/start/)
  * Run `minikube`
    * example run command: ```minikube --memory 8192 --cpus 4 start```
    * make sure you have enough resources allocated to your docker
* Run webhookie
  * Available options:
    * --auth=`issuer.env`
      * default is `keycloak` if you don't set this option
      * you can create your own `issuer.env` file similar to `auth0.env` sample and set it
    * --arm
      * if you're running on arm machines e.g. M1 or M2 Macs
      * script will detect it but you can specify
    * --with-demo
      * bring sample subscription-demo app can be used to for callbacks
      * default is without demo
    * --with-monitoring
      * brings `grafana` and `prometeous`
      * default is without monitoring
    * --with-logging
      * brings `elk stack`
      * default is without logging
  * Sample command:
    * ```./webhookie.sh --arm --with-demo --with-monitoring  --with-logging```
