//
//  MySQLDatabaseManager.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

import MySQLKit
import FluentMySQLDriver

/// Class that manages operations to MySQL.
public final class MySQLDatabaseManager {
    
    // MARK: Properties
    
    /// Standard global instance of this class.
    public static var `default` = {
        MySQLDatabaseManager(
            hostname: "localhost",
            username: "root",
            password: "root",
            database: "database"
        )
    }()
    
    private let databases: Databases
    
    private let databaseId: DatabaseID
    
    private let logger: Logger = Logger(label: "li.addr.MySQLDatabaseManager")
    
    public init(
        hostname: String,
        port: Int = 3306,
        username: String,
        password: String,
        database: String,
        tlsConfiguration: TLSConfiguration? = .forClient(certificateVerification: .none),
        maxConnectionsPerEventLoop: Int = 1,
        connectionPoolTimeout: NIO.TimeAmount = .seconds(10),
        encoder: MySQLDataEncoder = .init(),
        decoder: MySQLDataDecoder = .init()
    ){
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
        
        let databases = Databases(threadPool: threadPool, on: eventLoopGroup)
        
        let databaseId = DatabaseID(string: database)
        
        databases.use(
            .mysql(
               hostname: hostname,
               port: port,
               username: username,
               password: password,
               database: database,
               tlsConfiguration: tlsConfiguration,
               maxConnectionsPerEventLoop: maxConnectionsPerEventLoop,
               connectionPoolTimeout: connectionPoolTimeout,
               encoder: encoder,
               decoder: decoder
            ),
            as: databaseId
        )
        
        self.databases = databases
        self.databaseId = databaseId
    }
    
    deinit {
        databases.shutdown()
    }
}


extension MySQLDatabaseManager{
    
    public var fluent: FluentKit.Database {
        guard let database = databases.database(databaseId, logger: logger, on: databases.eventLoopGroup.next()) else{
            fatalError("Database create is failed.")
        }
        return database
    }
    
    public var mysql: MySQLNIO.MySQLDatabase {
        guard let mysql = self.fluent as? MySQLDatabase else{
            fatalError("Cast failed. Check for Vapor implementation?")
        }
        return mysql
    }
    
    public var sql: SQLKit.SQLDatabase {
        guard let sql = self.fluent as? SQLDatabase else{
            fatalError("Cast failed. Check for Vapor implementation?")
        }
        return sql
    }
    
}
