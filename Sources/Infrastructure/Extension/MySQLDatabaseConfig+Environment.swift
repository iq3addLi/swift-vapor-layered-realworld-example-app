//
//  MySQLDatabaseConfig+Environment.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/11/14.
//

import FluentMySQL

extension MySQLDatabaseConfig {

    static var fromEnvironment: Self {
        guard
            let hostname = ProcessInfo.processInfo.environment["MYSQL_HOSTNAME"],
            let username = ProcessInfo.processInfo.environment["MYSQL_USERNAME"],
            let password = ProcessInfo.processInfo.environment["MYSQL_PASSWORD"],
            let database = ProcessInfo.processInfo.environment["MYSQL_DATABASE"]
        else {
            return Self.root(database: "default")
        }
        return MySQLDatabaseConfig(hostname: hostname, username: username, password: password, database: database)
    }
}
