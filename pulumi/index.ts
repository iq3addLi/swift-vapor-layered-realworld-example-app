import * as pulumi from "@pulumi/pulumi"
import * as aws from "@pulumi/aws"
import * as awsx from "@pulumi/awsx"

// Common settings
const prefix = "svlre"
const config = new pulumi.Config()

const mysqlUsername = config.require("mysqlUser")
const mysqlPassword = config.requireSecret("mysqlPassword")
const mysqlDatabase = config.require("mysqlDatabase")

const secretForJWT = config.require("secretForJWT")

// Create a VPC and a Cluster in it
const vpc = new awsx.ec2.Vpc( prefix + "-vpc", {
    cidrBlock: "10.0.0.0/16"
})
const cluster = new awsx.ecs.Cluster( prefix + "-cluster", {
    vpc: vpc
})


// Create mysql service with task
const mysqlPrefix = prefix + "-mysql"
const mysqlListener = new awsx.elasticloadbalancingv2.NetworkListener( mysqlPrefix + "-listener", {
    vpc: vpc,
    port: 3306
})
const mysqlTaskDefinition = new awsx.ecs.FargateTaskDefinition( mysqlPrefix + "-taskdef", {
    container: {
        image: "mysql:5.7",
        cpu: 1,
        memory: 256,
        portMappings: [ mysqlListener ],
        environment: [
            { name: "MYSQL_ROOT_PASSWORD", value: "rootpass" },
            { name: "MYSQL_USER",     value: mysqlUsername },
            { name: "MYSQL_PASSWORD", value: mysqlPassword },
            { name: "MYSQL_DATABASE", value: mysqlDatabase }
        ]
    }
})
const mysqlService = new awsx.ecs.FargateService( mysqlPrefix + "-mysql-service", {
    cluster: cluster,
    taskDefinition: mysqlTaskDefinition,
    desiredCount: 1
})
export const mysqlHost = mysqlListener.endpoint.hostname


// Create application service with task
const appPrefix = prefix + "-app"
const appListener = new awsx.elasticloadbalancingv2.ApplicationListener( appPrefix + "-listener", { 
    vpc: vpc,
    port: 80 
})
const appTaskDefinition = new awsx.ecs.FargateTaskDefinition( appPrefix + "-taskdef", {
    container: {
        image: awsx.ecs.Image.fromPath( appPrefix + "-image", "../"),
        cpu: 1, /* Unit count */
        memory: 128, /*MB*/
        portMappings: [ appListener ],
        environment: [
            { name: "MYSQL_USERNAME", value: mysqlUsername },
            { name: "MYSQL_PASSWORD", value: mysqlPassword },
            { name: "MYSQL_DATABASE", value: mysqlDatabase },
            { name: "MYSQL_HOSTNAME", value: mysqlHost },
            { name: "SECRET_FOR_JWT", value: secretForJWT }
        ]
    }
})
const appService = new awsx.ecs.FargateService( appPrefix + "-app-service", {
    cluster: cluster,
    taskDefinition: appTaskDefinition,
    desiredCount: 1
})
export const appHost = appListener.endpoint.hostname
