# Deploy webhookie using docker-compose 
This README helps get up and running webhookie using **docker-compose**

# Dependencies

Docker v20.10 or above is required.

# Get Started
- To get started using `bash` use `./webhookie.sh`
- To get started using powershell use `./webhookie.ps1`

To get full understanding of the options to customize deployment and branding use `--help`

To understand more about `webhookie` architecture and concepts please go to [webhookie docs](https://webhookie.com/docs) 
  
### Examples:
- #### Example 1: Runs on M1 mac adding logging capability

```#!/bin/sh
./webhookie.sh --arm --with-logging
```

- #### Example 2: Runs adding monitoring and subscription sample capability

```#!/bin/sh
./webhookie.sh --with-logging --with-sample
```

- #### Example 3: Runs with setting the mail color

```#!/bin/sh
./webhookie.sh --branding-color=#030303
```

- #### Example 4: Runs with whitelabel

```#!/bin/sh
./webhookie.sh --branding=./my-branding
```
