//
//  DatabaseManager.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

import FluentMySQL
import Dispatch

/// dummy comment
public class MySQLDatabaseManager{
    
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
    
//    private lazy var worker = {
//        MultiThreadedEventLoopGroup(numberOfThreads: 1)
//    }()
//
//    private lazy var connectionPool: DatabaseConnectionPool = {
//        DatabaseConnectionPool(config: DatabaseConnectionPoolConfig(maxConnections: 10 * 10), database: database)
//    }()
    
    /// dummy comment
    public init(){}
    
//    deinit {
//        worker.shutdownGracefully { (error) in
//            print("\(error != nil ? error!.localizedDescription : "Unexpected failed to thread destruct.")")
//        }
//    }
    
    /// dummy comment
    public func requestConnection(on worker: Worker ) -> Future<MySQLConnection>{
        //print("worker (\(worker)) of hash is \( (worker as AnyObject).hash ?? 0 )")
        return connectionPoolCache.requestConnectionToPool(on: worker.eventLoop)
    }
    
    /// dummy comment
    public func connectionOnInstantEventLoop() -> Future<MySQLConnection>{
        return database.newConnection(on: MultiThreadedEventLoopGroup(numberOfThreads: 1))
    }
    
    public func correctInstantEventLoop( connection: MySQLConnection){
        connection.eventLoop.shutdownGracefully { (error) in
            print("\(error != nil ? error!.localizedDescription : "shutdownGracefully was successed.")")
        }
    }
    
    /// dummy comment
    public func connectionOnCurrentEventLoop() -> Future<MySQLConnection>{
        guard let worker = MultiThreadedEventLoopGroup.currentEventLoop else{
            fatalError("connectionOnCurrentEventLoop() is need execute on EventLoopGroup.")
        }
        return requestConnection(on: worker)
    }
    
    public func releaseConnection(_ connection: MySQLConnection) {
        guard let worker = MultiThreadedEventLoopGroup.currentEventLoop else{
            fatalError("connectionOnCurrentEventLoop() is need execute on EventLoopGroup.")
        }
        // to inactive state for connection
        connectionPoolCache.releaseConnectionToPool(on: worker, connection: connection)
    }
}
