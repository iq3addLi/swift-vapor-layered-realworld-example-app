//
//  StandaloneDatabaseConnectionPoolCache.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/11/26.
//

import DatabaseKit

internal final class StandaloneDatabaseConnectionPoolCache<Database> where Database: DatabaseKit.Database {

    /// The source databases.
    private let database: Database

    /// The pool configuration settings.
    private let config: DatabaseConnectionPoolConfig

    /// The cached connection pools on thread.
    private let threadVariablePools: ThreadSpecificVariable<DatabaseConnectionPool<Database>> // Note: https://github.com/apple/swift-nio/blob/2.10.1/Sources/NIO/Thread.swift#L154-L157 has deinit, but https://github.com/apple/swift-nio/blob/1.14.1/Sources/NIO/Thread.swift hasn't deinit. So do it manually.

    /// Creates a new `DatabaseConnectionPoolCache`.
    internal init(database: Database, config: DatabaseConnectionPoolConfig) {
        self.database = database
        self.config = config
        self.threadVariablePools = ThreadSpecificVariable<DatabaseConnectionPool<Database>>()
    }

    deinit {
        threadVariablePools.release()
    }

    internal func requestConnectionToPool() -> Future<Database.Connection> {
        guard let eventLoop = MultiThreadedEventLoopGroup.currentEventLoop else {
            fatalError("connectionOnCurrentEventLoop() is need execute on EventLoopGroup.")
        }
        return ( threadVariablePools.currentValue ?? {
            let pool = database.newConnectionPool(config: config, on: eventLoop)
            threadVariablePools.currentValue = pool
            return pool
        }()).requestConnection()
    }

    internal func releaseConnectionToPool(connection: Database.Connection) {
        guard let pool = threadVariablePools.currentValue else {
            fatalError("A connection pool was not found.")
        }
        pool.releaseConnection(connection)
    }
}

extension ThreadSpecificVariable {
    fileprivate func release() {
        let pthreadErr = pthread_key_delete(pthread_key_t())
        precondition(pthreadErr == 0, "pthread_key_delete failed, error \(pthreadErr)")
    }
}
