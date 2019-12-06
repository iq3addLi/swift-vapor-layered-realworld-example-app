//
//  VaporFrameworkRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//

import Vapor

/// FrameworkRepository implemented in Vapor.
class VaporApplicationRepository: RESTApplicationRepository {
    
    // MARK: Properties
    
    /// See `Services`.
    private lazy var services = {
        return Services.default()
    }()
    
    /// See `Vapor.Application`.
    private var application: Vapor.Application?

    
    // MARK: Functions
    
    /// Perform initialization processing for Vapor.
    ///
    /// In this function:
    /// * Configure CORS to respond from different domains.
    /// * Configure `ErrorMidlleware` to convert an error that occurred in the controller to a response that conforms to Realworld specifications.
    /// * Set `ServiceType` to relay from Middleware to Controller.
    func initalize() {
        
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

        // Apply change service
        services.register(middlewares)
        
        // Set transferable type
        services.register(VerifiedUser.self)
        services.register(VerifiedUserEntity.self)
    }
    
    /// Vapor's Router initialization process.
    /// - Parameter collections: Routing instruction array. See `APICollection`.
    func routing(collections: [APICollection]) {
        
        var services = self.services

        // Register routes to the router
        let router = EngineRouter.default()

        // Basic "It works" example
        router.get { _ -> String in
            return "It works!"
        }

        // Set Routing
        collections.forEach { collection in
            router.grouped(collection.middlewares)
                .on(collection.method.raw, at: collection.paths, use: collection.closure )
        }

        // Set router
        services.register(router, as: Router.self)
    }
    
    /// Start `Vapor.Application`.
    /// - Parameters:
    ///   - hostname: Host name where the server starts. ex. `"127.0.0.1"`.
    ///   - port: Server port number. ex. `80`.
    /// - throws:
    ///    <#Description#> 
    func applicationLaunch(hostname: String, port: Int) throws {
        
        var services = self.services
        // Set server config
        let config = NIOServerConfig.default(hostname: "127.0.0.1", port: 8080)
        services.register(config)
        
        // Create vapor application
        let application = try Application(config: Config.default(),
                                          environment: try Environment.detect(),
                                          services: services)
        // Application launch
        try application.run()
        self.application = application
    }
    
    
    /// Error handler provided for this project.
    ///
    /// See `ErrorMiddleware` for detail.
    /// - Parameters:
    ///   - request: See `ErrorMiddleware.closure`.
    ///   - error: See `ErrorMiddleware.closure`.
    /// - returns:
    ///    <#Description#>   
    private func errorToResponse( request: Request, error: Swift.Error ) -> Response {

        do {
            // inspect the error type
            switch error {
            case let abort as AbortError: return try abort.toResponse(for: request)
            case let validation as ValidationError: return try validation.toResponse(for: request)
            case let debuggable as Debuggable: return try debuggable.toResponse(for: request)
            case let domainError as Domain.Error: return try domainError.toResponse(for: request)
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
