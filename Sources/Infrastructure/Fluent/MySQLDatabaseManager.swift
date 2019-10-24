//
//  DatabaseManager.swift
//  Infrastructure
//
//  Created by iq3AddLi on 2019/10/09.
//

import FluentMySQL
import Dispatch

public class MySQLDatabaseManager{
    
    private lazy var database: MySQLDatabase = {
        let config = MySQLDatabaseConfig(hostname: "127.0.0.1", username: "root", password: "rootpassword", database: "realworld_test")
        
        return MySQLDatabase(config: config)
    }()
    
    private lazy var worker: Worker = {
        return MultiThreadedEventLoopGroup(numberOfThreads: 2)
    }()
    
    public init(){}
    
    deinit {
        worker.shutdownGracefully{ (error) in
            if let error = error{
                print("Worker shutdown is failed. reason=\(error)")
            }
        }
    }
    
    public func newConnection() throws -> MySQLConnection{
        return try futureConnection().wait()
    }
    
    public func futureConnection() -> Future<MySQLConnection>{
        return database.newConnection(on: self.worker.next())
    }
}


// MARK: TRANSACTION
extension MySQLDatabaseManager{

    public func futureTransaction() -> Future<MySQLConnection>{
        
        // Connection and start transaction
        var connection: MySQLConnection?
        let future = futureConnection()
            .flatMap{ conn -> Future<[[MySQLColumn: MySQLData]]> /* Without this specification I will be beaten by the compiler. F**k☺️ */ in
                connection = conn
                return conn.simpleQuery("START TRANSACTION")
            }.map { _ -> MySQLConnection in
                connection!
            }
        
        future.whenFailure { _ in
            _ = connection?.simpleQuery("ROLLBACK")
        }
        
        future.whenSuccess { _ in
            _ = connection?.simpleQuery("COMMIT")
        }
        
        return future
    }
    
    public func startTransaction<T>(_ transactionClosure:(_ connection: MySQLConnection) throws -> T ) throws -> T{
        // Connection and start transaction
        let connection = try newConnection()
        _ = try connection.simpleQuery("START TRANSACTION").wait()
        
        // Execute transaction
        let result: T
        do {
            result = try transactionClosure(connection)
        }catch( let error ){
            _ = try connection.simpleQuery("ROLLBACK").wait()
            throw error
        }
        _ = try connection.simpleQuery("COMMIT").wait()
        
        return result
    }
}
