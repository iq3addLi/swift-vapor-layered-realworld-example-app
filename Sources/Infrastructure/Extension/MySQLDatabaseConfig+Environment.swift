//
//  MySQLDatabaseConfig+Environment.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/11/14.
//

import FluentMySQLDriver

/// Extension for MySQLDatabaseConfig.
extension MySQLDatabaseConfig {

    // MARK: Use environment
    
    /// Generate Config from environment variables.
    static var fromEnvironment: Self {
        guard
            let hostname = ProcessInfo.processInfo.environment["MYSQL_HOSTNAME"],
            let username = ProcessInfo.processInfo.environment["MYSQL_USERNAME"],
            let password = ProcessInfo.processInfo.environment["MYSQL_PASSWORD"],
            let database = ProcessInfo.processInfo.environment["MYSQL_DATABASE"]
        else {
            fatalError("""
                        The environment variable for MySQL must be set to start the application.
                        "MYSQL_HOSTNAME", "MYSQL_USERNAME", "MYSQL_PASSWORD" and "MYSQL_DATABASE".
                        """)
        }
        return MySQLDatabaseConfig(hostname: hostname, username: username, password: password, database: database)
    }
}
