//
//  ApplicationUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import FluentSQLite

public class ApplicationUseCase{
    
    private lazy var services = {
        return Services.default()
    }()
    private var application: Vapor.Application?
    
    public init(){
        
    }
    
    public func initialize() throws{
        
        var services = self.services
        
        // Set Fluent
        try services.register(FluentSQLiteProvider())
        
        // Register middleware
        var middlewares = MiddlewareConfig() // Create _empty_ middleware config
        // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
        middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
        
        services.register(middlewares)
        
        // Configure a SQLite database
        let sqlite = try SQLiteDatabase(storage: .memory)
        
        // Register the configured SQLite database to the database config.
        var databases = DatabasesConfig()
        databases.add(database: sqlite, as: .sqlite)
        services.register(databases)
        
        // Configure migrations
//        var migrations = MigrationConfig()
//        migrations.add(model: Todo.self, database: .sqlite)
//        services.register(migrations)
        
        self.services = services
    }
    
    public func routing(collections: [APICollection] ){
        
        var services = self.services
        
        // Register routes to the router
        let router = EngineRouter.default()
        
        // Basic "It works" example
        router.get { req in
            return "It works!"
        }
        
        // Basic "Hello, world!" example
        router.get("hello") { req in
            return Profile(username: "hello", bio: "world", image: "http://notfound", following: true)
        }
        
        collections.forEach{ collection in
            switch collection.method{
            case .GET: router.get(collection.paths, use: collection.closure)
            case .POST: router.post(collection.paths, use: collection.closure)
            case .PUT: router.put(collection.paths, use: collection.closure)
            case .DELETE: router.delete(collection.paths, use: collection.closure)
            default:
                fatalError("Unexpected http method.")
            }
        }
        
        services.register(router, as: Router.self)
        self.services = services
    }
    
    public func launch() throws{
        let config = Config.default()
        let env = try Environment.detect()
        
        // Create vapor application
        let application = try Application(config: config, environment: env, services: self.services)
        // Application launch
        try application.run()
        self.application = application
    }
    
}
