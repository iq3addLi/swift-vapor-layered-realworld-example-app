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
        MySQLDatabase(config: MySQLDatabaseConfig.fromEnvironment)
    }()
    
    private lazy var worker = {
        MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }()
    
    /// dummy comment
    public init(){}
    
    /// dummy comment
    public func newConnection(on worker: Worker ) -> Future<MySQLConnection>{
        database.newConnection(on: worker)
    }
    
    /// dummy comment
    public func futureConnection() -> Future<MySQLConnection>{
        database.newConnection(on: self.worker)
    }
    
    /// dummy comment
    public func connectionOnCurrentEventLoop() -> Future<MySQLConnection>{
        guard let worker = MultiThreadedEventLoopGroup.currentEventLoop else{
            fatalError("connectionOnCurrentEventLoop() is need execute on EventLoopGroup.")
        }
        return newConnection(on: worker)
    }
}
