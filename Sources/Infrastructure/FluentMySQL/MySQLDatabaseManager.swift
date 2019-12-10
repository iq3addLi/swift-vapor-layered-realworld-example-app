//
//  DatabaseManager.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

import MySQL

/// Class that manages operations to MySQL.
public class MySQLDatabaseManager {
    
    // MARK: Properties
    
    /// Standard global instance of this class.
    public static var `default` = {
        MySQLDatabaseManager()
    }()

    /// MySQL connectionPool cache. See `StandaloneDatabaseConnectionPoolCache`.
    private lazy var connectionPoolCache = {
        StandaloneDatabaseConnectionPoolCache<MySQLDatabase>(
            database: database,
            config: DatabaseConnectionPoolConfig(maxConnections: 10))
    }()

    /// See `MySQLDatabase`.
    private lazy var database = {
        MySQLDatabase(config: MySQLDatabaseConfig.fromEnvironment)
    }()

    // MARK: Initializer
    
    /// Default initializer.
    public init() {}

    
    // MARK: Operations from main thread
    
    /// Request connection on new temporary Thread.
    ///
    /// `MySQLDatabase` requires that the connection request be made with NIO.Thread. You can use this method when you want to request a connection from the main thread. Temporary threads are not automatically shut down. If you don't need to manually shut down, you should use `instantCommunication`.
    /// - returns:
    ///    The `Future` that returns `MySQLConnection`.
    /// - warning:
    ///    Never call it from NIO.Thread.
    public func newConnectionOnInstantEventLoop() -> Future<MySQLConnection> {
        print("Launch instant thread.")
        return database.newConnection(on: MultiThreadedEventLoopGroup(numberOfThreads: 1))
    }

    
    /// Shutdown eventLoop of connection.
    ///
    /// This method is paired with `newConnectionOnInstantEventLoop`. The created connection should be cleaned up with this method. `InstantCommunication` uses this method after executing the closure.
    /// - Parameter connection: Connections that have been used.
    /// - warnings:
    ///    Never call it from NIO.Thread.
    public func correctInstantEventLoop(connection: MySQLConnection) {
        connection.eventLoop.shutdownGracefully { (error) in
            print("\(error != nil ? error!.localizedDescription : "A shutdownGracefully by instant thread was successed.")")
        }
    }
    
    /// Communication with MySQL on a temporary Thread.
    ///
    /// Similar to `communication`. This is supposed to be called from Main Thread.
    /// - Parameters:
    ///   - closure: Receiving active conection closure.
    /// - returns:
    ///    The `Future` that returns `closure`'s return value.
    /// - warning:
    ///    Never call it from NIO.Thread.
    public func instantCommunication<T>( closure: @escaping (MySQLConnection) -> Future<T> ) -> Future<T> {
        var connection: MySQLConnection?
        return newConnectionOnInstantEventLoop()
            .flatMap { conn in
                connection = conn
                return closure(conn)
            }
            .always { [weak self] in
                if let conn = connection { self?.correctInstantEventLoop(connection: conn) }
            }
    }
    
    
    // MARK: Operations from NIO.Thread
    
    /// Request connection.
    ///
    /// This is supposed to be called on `NIO.Thread`. Connections called with this method must later notify the ConnectionPool that use has ended. Notify that the use has ended with `releaseConnection`. If you don't need to manually release, you should use `communication` or `transaction`.
    /// - returns:
    ///    The `Future` that returns `MySQLConnection`.
    /// - warnings:
    ///    Never call it from main thread.
    public func requestConnection() -> Future<MySQLConnection> {
        connectionPoolCache.requestConnectionToPool()
    }

    /// Release connection.
    ///
    /// This method is paired with `requestConnection`. The requested connection should be released with this method. `communication` and `transaction` uses this method after executing the closure.
    /// - Parameter connection: Connections that have been used.
    /// - returns:
    ///    The `Future` that returns `MySQLConnection`.
    /// - warnings:
    ///    Never call it from main thread.
    public func releaseConnection(_ connection: MySQLConnection) {
        // to inactive state for connection
        connectionPoolCache.releaseConnectionToPool(connection: connection)
    }

    /// Communication with MySQL.
    ///
    /// Request and release a connection. In the meantime, you can specify a closure that uses connection.
    /// - Parameter closure: Receiving active conection closure.
    /// - returns:
    ///    The `Future` that returns `closure`'s return value.
    /// - warnings:
    ///    Never call it from main thread.
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
    
    /// Communication with MySQL with Transaction enabled.
    ///
    /// Similar to `communication`. The difference is that the MySQL transaction feature is enabled. This should be used when running CUD Operations.
    /// - Parameter closure: Receiving active conection closure.
    /// - returns:
    ///    The `Future` that returns `closure`'s return value. 
    /// - warnings:
    ///    Never call it from main thread.
    public func transaction<T>( closure: @escaping (MySQLConnection) -> Future<T> ) -> Future<T> {
        communication { connection in
            connection.transaction(on: .mysql) { connectionOnTransaction in
                closure(connectionOnTransaction)
            }
        }
    }
    
}
