//
//  ApplicationUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Infrastructure

/// <#Description#>
public class ApplicationUseCase: UseCase{
    
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
        var middlewares = MiddlewareConfig() // Create _empty_ middleware config
        
        // Set custom CORS middleware
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
        )
        let corsMiddleware = CORSMiddleware(configuration: corsConfig)
        middlewares.use(corsMiddleware)
        
        // Set custom error handler
        middlewares.use(ErrorMiddleware(errorToResponse)) // Catches errors and converts to HTTP response
        
        // test
        try self.conduit.ifneededPreparetion()
        
        // Apply change service
        services.register(middlewares)
        self.services = services
    }
    
    /// <#Description#>
    /// - parameters:
    ///     - collections: <#collections description#>
    /// - returns:
    ///    (dummy)
    public func routing( collections: [APICollection] ){
        
        var services = self.services
        
        // Register routes to the router
        let router = EngineRouter.default()
        
        // Basic "It works" example
        router.get { req -> String in
            return "It works!"
        }
        
        // Set Routing
        collections.forEach{ collection in
            router.grouped(collection.middlewares)
                .on(collection.method.raw, at: collection.paths, use: collection.closure )
        }
        
        // Set router
        services.register(router, as: Router.self)
        
        // Set transferable type
        services.register(AuthedUser.self)
        services.register(VerifiedUserEntity.self)
        
        
        // Set server config
        let config = NIOServerConfig.default(hostname: "127.0.0.1", port: 8080)
        services.register(config)
        
        // Apply change service
        self.services = services
    }
    
    
    /// <#Description#>
    public func launch() throws{
        // Create vapor application
        let application = try Application(config: Config.default(),
                                          environment: try Environment.detect(),
                                          services: self.services)
        // Application launch
        try application.run()
        self.application = application
    }
    
    
    /// <#Description#>
    /// - Parameter request: <#request description#>
    /// - Parameter error: <#error description#>
    private func errorToResponse( request: Request, error: Swift.Error ) -> Response {
    
        do{
            // inspect the error type
            switch error {
            case let abort as AbortError: return try abort.toResponse(for: request)
            case let validation as ValidationError: return try validation.toResponse(for: request)
            case let debuggable as Debuggable: return try debuggable.toResponse(for: request)
            default:
                // not an abort error, and not debuggable or in dev mode
                // just deliver a generic 500 to avoid exposing any sensitive error info
                let response = request.response(http: .init(status: .internalServerError, headers: [:]))
                response.http.body = try HTTPBody(data: JSONEncoder().encode(GenericErrorModel(errors: GenericErrorModelErrors(body: [error.localizedDescription]))))
                response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
                return response
            }
        } catch {
            let response = request.response(http: .init(status: .internalServerError, headers: [:]))
            response.http.body = HTTPBody(string: "Oops: \(error)")
            response.http.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            return response
        }
        
    }
}



extension AbortError{
    
    /// <#Description#>
    /// - Parameter request: <#request description#>
    func toResponse(for request: Request) throws -> Response{
        // this is an abort error, we should use its status, reason, and headers
        let response = request.response(http: .init(status: status, headers: headers))
        response.http.body = try HTTPBody(data: JSONEncoder().encode(GenericErrorModel(errors: GenericErrorModelErrors(body: [reason]))))
        response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
    }
}

extension Debuggable{
    
    /// <#Description#>
    /// - Parameter request: <#request description#>
    func toResponse(for request: Request) throws -> Response{
        // if not release mode, and error is debuggable, provide debug
        // info directly to the developer
        let response = request.response(http: .init(status: .internalServerError, headers: [:]))
        response.http.body = try HTTPBody(data: JSONEncoder().encode(GenericErrorModel(errors: GenericErrorModelErrors(body: [reason]))))
        response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
        
    }
}

extension ValidationError{
    
    /// <#Description#>
    /// - Parameter request: <#request description#>
    func toResponse(for request: Request) throws -> Response{
        let response = request.response(http: .init(status: .badRequest, headers: [:]))
        response.http.body = try HTTPBody(data: JSONEncoder().encode(self))
        response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
        return response
    }
}
