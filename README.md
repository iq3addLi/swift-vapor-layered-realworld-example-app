[![RealWorld Frontend](https://img.shields.io/badge/realworld-backend-%23783578.svg)](http://realworld.io)  [![swift.org](https://img.shields.io/badge/swift-5.4-orange.svg?logo=swift)](https://swift.org)  [![Vapor Documentation](http://img.shields.io/badge/💧_vapor-4-2196f3.svg)](https://github.com/vapor/vapor)  [![API Doc](https://img.shields.io/badge/Project's_domain-doc-brightgreen.svg)](https://iq3addli.github.io/swift-vapor-layered-realworld-example-app)  [![My frontend](https://img.shields.io/badge/Frontend-here-red.svg)](https://github.com/iq3addLi/riot_v4_realworld_example_app)

# ![RealWorld Example App](logo.png)

> ### Vapor codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld) spec and API.

[Demo](https://github.com/gothinkster/realworld)&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld](https://github.com/gothinkster/realworld) 


This codebase was created to demonstrate a fully fledged fullstack application built with **Vapor** including CRUD operations, authentication, routing, pagination, and more.

We've gone to great lengths to adhere to the **Vapor** community styleguides & best practices.

For more information on how to this works with other frontends/backends, head over to the [RealWorld](https://github.com/gothinkster/realworld) repo.

[toc]

# How it works

## On local

### Precondition

* Your platform is Linux or Mac.
* Swift 5.4 or over than is installed.
* Docker is installed.

### Build RealWorld App

```bash
$ swift build -c release 
```

### Launch container of MySQL

```bash
$ docker-compose up
```

### Generate secret for JWT

```bash
$ echo "Your rememberable word" | md5
```

This can be your favorite method.

### Set environment variables

```bash
$ export SECRET_FOR_JWT={{ secret for JWT }} \
  MYSQL_HOSTNAME=0.0.0.0 \
  MYSQL_USERNAME=mysqluser \
  MYSQL_PASSWORD=mysqlpass \
  MYSQL_DATABASE=mysqldatabase
```

This setting values is editable, but it needs to match the setting in [docker-compose.yml](./docker-compose.yml).

### Launch RealWorld App 

```bash
$ .build/release/realworld serve --hostname 0.0.0.0 --port 8080
```

### Stop servers

By `Control + C` on launched terminal. Will stop MySQL and App.



## On local container (For non-Mac)

### Precondition

* Docker is installed.

### Build container for RealWorld App

```bash
$ docker build -t realworld:latest .
```

### Create network for local servers

```zsh
$ docker network create realworld-network
```

### Set environments for MySQL

```bash
$ export MYSQL_USERNAME=mysqluser \
  MYSQL_PASSWORD=mysqlpass \
  MYSQL_DATABASE=mysqldatabase \
  MYSQL_ROOTPASS=rootpass
```

This setting values is editable.  Note that the value set at the beginning is recorded. 

### Launch container of MySQL

```bash
$ docker run -d --rm \
    --name mysql-server \
    --network realworld-network \
    --env MYSQL_USER=${MYSQL_USERNAME} \
    --env MYSQL_PASSWORD=${MYSQL_PASSWORD} \
    --env MYSQL_DATABASE=${MYSQL_DATABASE} \
    --env MYSQL_ROOT_PASSWORD=${MYSQL_ROOTPASS} \
    -v ${PWD}/mysql_data:/var/lib/mysql \
    -p 3306:3306 \
    mysql:5.7 \
      --character-set-server=utf8mb4 \
      --collation-server=utf8mb4_unicode_ci
```

### Launch container of RealWorld App 

```bash
$ docker run -d --rm \
    --name app-server \
    --network realworld-network \
    --env SECRET_FOR_JWT={{ secret for JWT }}\
    --env MYSQL_USERNAME=${MYSQL_USERNAME}\
    --env MYSQL_PASSWORD=${MYSQL_PASSWORD}\
    --env MYSQL_DATABASE=${MYSQL_DATABASE}\
    --env MYSQL_HOSTNAME="mysql-server" \
    -p 8080:80 \
    realworld:latest
```

`Server starting on http://0.0.0.0:80`  is displayed. But it opens at http://0.0.0.0:8080 .

### Stop containers

```bash
$ docker ps
$ docker stop {{ CONTAINER ID or NAME for MySQL }} {{ CONTAINER ID or NAME for RealWorld App }}
```



## On AWS Fargate by pulumi

### Precondition

* You have AWS and pulumi account.
* AWS and Pulumi CLI is Installed.

### Set environments for AWS CLI

```bash
$ set +o history # disable record to bash_history 
$ export AWS_ACCESS_KEY_ID={{ Your access key id of AWS account }}
$ export AWS_SECRET_ACCESS_KEY={{ Your access key secret of AWS account }}
$ set -o history
$ clear # flush terminal
```

### Set config to Pulumi.dev.yaml[Optional]

```bash
$ pulumi config set mysqlDatabase mysqldatabase
$ pulumi config set --secret mysqlPassword mysqlPass
$ pulumi config set mysqlUser mysqluser
$ pulumi config set secretForJWT {{ secret for JWT }}
```

### Preview pulumi stack

```bash
$ cd pulumi
$ pulumi preview
```

### Deploying pulumi stack

```bash
$ pulumi up --yes
```
In this case, the connection settings is listed in [pulumi/Pulumi.dev.yaml](pulumi/Pulumi.dev.yaml). 

When processing is complete, the host names for MySQL and APP will be displayed. 

```bash
Outputs:
    appHost  : "svlre-app-listener-*.us-east-1.elb.amazonaws.com"
    mysqlHost: "svlre-mysql-listener-*.elb.us-east-1.amazonaws.com"
```

Everyone using AWS. I think you know well. **Launched resources are expensive💸**. Clean up resources when you are done.

### Clean up pulumi stack

```bash
$ pulumi destroy --yes
```

⚠️ MySQL storage is volatile.



# Getting started

## Open Project
Open `Package.swift` by latest Xcode.    
SwiftPM will automatically resolve all the dependencies, and when it is done, you can build.

## Set environment variables
Required the first time.  
Set the environment variables in menu  `Product > Scheme > Edit scheme > Run > arguments`  

key | value (example)
:---|:---
HOSTNAME|0.0.0.0
PORT|8080
MYSQL_HOSTNAME|0.0.0.0
MYSQL_USERNAME|mysqluser
MYSQL_PASSWORD|mysqlpass
MYSQL_DATABASE|mysqldatabase
SECRET_FOR_JWT|secret

Another way, Put `.env` on the same directory as the executable binary.  
You can find it in the `Env` directory.

## Code entrance

[Sources/realworld/main.swift](Sources/realworld/main.swift) is code of entrance. From here you can follow the entire code!



## Connect with Frontend Realworld

Change your Realworld frontend Server host settings.  If you are using the Riot version, see [here](https://github.com/iq3addLi/riot_v4_realworld_example_app#change-api-server).

