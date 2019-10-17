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
        do{
            try worker.syncShutdownGracefully()
        }catch(let error){
            print("Worker shutdown is failed. reason=\(error)")
        }
    }
    
    public func newConnection() throws -> MySQLConnection{
        return try database.newConnection(on: self.worker).wait()
    }
    
    public func futureConnection() -> Future<MySQLConnection>{
        return database.newConnection(on: self.worker)
    }
//    public func beginTransaction() throws -> MySQLConnection{
//        database.
//    }
}

