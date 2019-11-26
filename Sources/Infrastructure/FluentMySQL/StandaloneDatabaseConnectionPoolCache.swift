//
//  StandaloneDatabaseConnectionPoolCache.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/11/26.
//

import DatabaseKit
import Async

internal final class StandaloneDatabaseConnectionPoolCache<Database> where Database: DatabaseKit.Database{

    /// The source databases.
    private let database: Database
    
    /// The cached connection pools.
    private var cache: [Int: DatabaseConnectionPool<Database>]

    /// The pool configuration settings.
    private let config: DatabaseConnectionPoolConfig

    /// Creates a new `DatabaseConnectionPoolCache`.
    internal init(database: Database, config: DatabaseConnectionPoolConfig) {
        self.database = database
        self.config = config
        self.cache = [:]
    }

    internal func requestConnectionToPool(on eventLoop: EventLoop) -> Future<Database.Connection>{
        guard let hash = (eventLoop as AnyObject).hash else{
            fatalError("The eventloop has not hash.")
        }
        
        return ( cache[hash] ?? {
            let pool = database.newConnectionPool(config: config, on: eventLoop)
            cache[hash] = pool
            return pool
        }()).requestConnection()
    }
    
    internal func releaseConnectionToPool(on eventLoop: EventLoop, connection: Database.Connection) {
        guard let hash = (eventLoop as AnyObject).hash else{
            fatalError("The eventloop has not hash.")
        }
        guard let pool = cache[hash] else{
            fatalError("A connection pool was not found.")
        }
        pool.releaseConnection(connection)
    }
}
