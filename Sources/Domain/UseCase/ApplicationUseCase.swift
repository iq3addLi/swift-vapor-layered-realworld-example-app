//
//  ApplicationUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import FluentMySQL


/// <#Description#>
public class ApplicationUseCase{
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    private lazy var services = {
        return Services.default()
    }()
    private var application: Vapor.Application?
    
    public init(){}
    
    
    /// <#Description#>
    /// - returns:
    ///    <#Description#>
    public func initialize() throws{
        
        var services = self.services
        
        // Register middlewares
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
        )
        let corsMiddleware = CORSMiddleware(configuration: corsConfig)
        
        var middlewares = MiddlewareConfig() // Create _empty_ middleware config
        middlewares.use(corsMiddleware)
        middlewares.use(ErrorMiddleware(errorToResponse)) // Catches errors and converts to HTTP response
        services.register(middlewares)
        
        // test
        self.conduit.ifneededPreparetion()
        
        // Apply change service
        self.services = services
    }
    
    /// <#Description#>
    /// - parameters:
    ///     - collections: <#collections description#>
    /// - returns:
    ///    (dummy)
    public func routing(collections: [APICollection] ){
        
        var services = self.services
        
        // Register routes to the router
        let router = EngineRouter.default()
        
        // Basic "It works" example
        router.get { req -> String in
            throw Abort( .badRequest )
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
    
    
    /// <#Description#>
    public func launch() throws{
        let config = Config.default()
        let env = try Environment.detect()
        
        // Create vapor application
        let application = try Application(config: config, environment: env, services: self.services)
        
        // Application launch
        try application.run()
        self.application = application
    }
    
    
    private func errorToResponse( request: Request, error: Swift.Error ) -> (Response) {
        
        // variables to determine
        let status: HTTPResponseStatus
        let reason: String
        let headers: HTTPHeaders

        // inspect the error type
        switch error {
        case let abort as AbortError:
            // this is an abort error, we should use its status, reason, and headers
            reason = abort.reason
            status = abort.status
            headers = abort.headers
        case let validation as ValidationError:
            // this is a validation error
            reason = validation.reason
            status = .badRequest
            headers = [:]
        case let debuggable as Debuggable:
            // if not release mode, and error is debuggable, provide debug
            // info directly to the developer
            reason = debuggable.reason
            status = .internalServerError
            headers = [:]
        default:
            // not an abort error, and not debuggable or in dev mode
            // just deliver a generic 500 to avoid exposing any sensitive error info
            reason = error.localizedDescription
            status = .internalServerError
            headers = [:]
        }

        // create a Response with appropriate status
        let response = request.response(http: .init(status: status, headers: headers))

        // attempt to serialize the error to json
        do {
            let errorResponse = ErrorResponse(errors:["body" : [reason]])
            response.http.body = try HTTPBody(data: JSONEncoder().encode(errorResponse))
            response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        } catch {
            response.http.body = HTTPBody(string: "Oops: \(error)")
            response.http.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
        }
        return response
    }
}
