//
//  VaporFrameworkRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//

import Vapor

/// REST Application implemented in Vapor.
class VaporApplicationRepository: RESTApplicationRepository {
    
    // MARK: Properties

    /// See `Vapor.Application`.
    lazy private var application: Vapor.Application = {
       Application()
    }()

    
    // MARK: Functions
    
    /// Perform initialization processing for Vapor.
    ///
    /// In this function:
    /// * Configure CORS to respond from different domains.
    /// * Configure `ErrorMidlleware` to convert an error that occurred in the controller to a response that conforms to Realworld specifications.
    /// * Set `ServiceType` to relay from Middleware to Controller.
    func initalize() {

        // Set custom CORS middleware
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
        )
        let corsMiddleware = CORSMiddleware(configuration: corsConfig)

        // Set custom error handler
        let errorHandleMiddleware = ErrorMiddleware(errorToResponse)
        
        application.middleware.use( corsMiddleware )
        application.middleware.use( errorHandleMiddleware )
    }
    
    /// Vapor's Router initialization process.
    /// - Parameter collections: Routing instruction array. See `APICollection`.
    func routing(collections: [APICollection]) {

        let app = application
        
        // Basic "It works" example
        app.get { _ -> String in
            return "It works!"
        }

        // Set Routing
        collections.forEach { collection in
            app.grouped(collection.middlewares)
                .on(collection.method.raw, collection.paths, use: collection.closure)
        }
    }
    
    /// Start `Vapor.Application`.
    /// - Parameters:
    ///   - hostname: Host name where the server starts. ex. `"127.0.0.1"`.
    ///   - port: Server port number. ex. `80`.
    /// - throws:
    ///    See `Application.init(config:environment:services:)`.
    func applicationLaunch(hostname: String, port: Int) throws {
        
        // Set server config
        application.http.server.configuration = HTTPServer.Configuration(
            hostname: hostname,
            port: port
        )
        
        // Application launch
        try application.run()
    }
    
    
    /// Error handler provided for this project.
    ///
    /// See `ErrorMiddleware` for detail.
    /// - Parameters:
    ///   - request: See `ErrorMiddleware.closure`.
    ///   - error: See `ErrorMiddleware.closure`.
    /// - returns:
    ///    A `Vapor.Response` that converted the error that reached this method according to the specifications of the project
    private func errorToResponse( request: Request, error: Swift.Error ) -> Response {

//        do {
//            // inspect the error type
//            switch error {
//            case let abort as AbortError: return try abort.toResponse(for: request)
//            case let validation as ValidationError: return try validation.toResponse(for: request)
//            case let debuggable as Debuggable: return try debuggable.toResponse(for: request)
//            case let domainError as Domain.Error: return try domainError.toResponse(for: request)
//            default:
//                // not an abort error, and not debuggable or in dev mode
//                // just deliver a generic 500 to avoid exposing any sensitive error info
//                let response = request.response(http: .init(status: .internalServerError, headers: [:]))
//                response.http.body = try HTTPBody(data: JSONEncoder().encode(GenericErrorModel(errors: GenericErrorModelErrors(body: [error.localizedDescription]))))
//                response.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
//                return response
//            }
//        } catch {
//            let response = request.response(http: .init(status: .internalServerError, headers: [:]))
//            response.http.body = HTTPBody(string: "Oops: \(error)")
//            response.http.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
//            return response
//        }

        // Dummy
        Response(
            status: .ok,
            version: .init(major: 2, minor: 0),
            headers: .init([("Content-Type", "text/plain; charset=utf-8")]),
            body: .init(string: "This response is dummy😣")
        )
    }
}
