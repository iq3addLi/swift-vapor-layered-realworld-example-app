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
    
    private lazy var database: MySQLDatabase = {
        let config = MySQLDatabaseConfig(hostname: "127.0.0.1", username: "root", password: "rootpassword", database: "realworld_test")
        
        return MySQLDatabase(config: config)
    }()
    
    /// dummy comment
    public init(){}
    
    /// dummy comment
    public func newConnection(on worker: Worker ) -> Future<MySQLConnection>{
        database.newConnection(on: worker)
    }
    
    /// dummy comment
    public func connectionOnCurrentEventLoop() -> Future<MySQLConnection>{
        guard let worker = MultiThreadedEventLoopGroup.currentEventLoop else{
            fatalError("connectionOnCurrentEventLoop() is need execute on EventLoopGroup.")
        }
        return newConnection(on: worker)
    }
}
