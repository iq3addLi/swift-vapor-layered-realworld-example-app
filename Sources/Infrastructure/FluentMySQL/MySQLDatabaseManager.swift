//
//  DatabaseManager.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

import FluentMySQL
import Dispatch

/// dummy comment
public class MySQLDatabaseManager {

    public static var `default` = {
        MySQLDatabaseManager()
    }()

    private lazy var connectionPoolCache = {
        StandaloneDatabaseConnectionPoolCache<MySQLDatabase>(
            database: database,
            config: DatabaseConnectionPoolConfig(maxConnections: 10))
    }()

    private lazy var database = {
        MySQLDatabase(config: MySQLDatabaseConfig.fromEnvironment)
    }()

    /// dummy comment
    public init() {}

    /// dummy comment
    public func requestConnectionOnInstantEventLoop() -> Future<MySQLConnection> {
        return database.newConnection(on: MultiThreadedEventLoopGroup(numberOfThreads: 1))
    }

    public func correctInstantEventLoop(connection: MySQLConnection) {
        connection.eventLoop.shutdownGracefully { (error) in
            print("\(error != nil ? error!.localizedDescription : "shutdownGracefully was successed.")")
        }
    }

    /// dummy comment
    public func requestConnection() -> Future<MySQLConnection> {
        return connectionPoolCache.requestConnectionToPool()
    }

    public func releaseConnection(_ connection: MySQLConnection) {
        // to inactive state for connection
        connectionPoolCache.releaseConnectionToPool(connection: connection)
    }

    public func communication<T>( closure: @escaping (MySQLConnection) -> Future<T> ) -> Future<T> {
        var connection: MySQLConnection?
        return requestConnection()
            .flatMap { conn in
                connection = conn
                return closure(conn)
            }
            .always { [weak self] in
                if let conn = connection { self?.releaseConnection(conn) }
            }
    }

    public func startTransaction<T>( closure: @escaping (MySQLConnection) -> Future<T> ) -> Future<T> {
        communication { connection in
            connection.transaction(on: .mysql) { connectionOnTransaction in
                closure(connectionOnTransaction)
            }
        }
    }
}
