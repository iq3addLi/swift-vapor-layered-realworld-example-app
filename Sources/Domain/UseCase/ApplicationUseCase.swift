//
//  ApplicationUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import FluentMySQL

public class ApplicationUseCase{
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    private lazy var services = {
        return Services.default()
    }()
    private var application: Vapor.Application?
    
    public init(){
        
    }
    
    public func initialize() throws{
        
        var services = self.services
        
        // Register middleware
        var middlewares = MiddlewareConfig() // Create _empty_ middleware config
        middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
        services.register(middlewares)
        
        // test
        self.conduit.ifneededPreparetion()
        
        // Apply change service
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
        
        // Set Routing
        collections.forEach{ collection in
            router.grouped(collection.middlewares)
                .on(collection.method.raw, at: collection.paths, use: collection.closure )
        }
        
        // Set router
        services.register(router, as: Router.self)
        
        // Set Service models
        services.register(AuthedUser()) // Initial property is blank.
        services.register(VerifiedUserEntity())
        
        
        // Set server config
        let config = NIOServerConfig.default(hostname: "127.0.0.1", port: 8000)
        services.register(config)
        
        // Apply change service
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
