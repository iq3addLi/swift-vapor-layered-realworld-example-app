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
    private let application: Vapor.Application
    
    
    init(){
        // reply envronments
        do{
            let env = try Environment.detect()
            application = Application(env)
        }catch{
            fatalError("Environment not found. Specify the environment with --env.")
        }
    }
    
    // MARK: Functions
    
    /// Perform initialization processing for Vapor.
    ///
    /// In this function:
    /// * Configure CORS to respond from different domains.
    /// * Configure `ErrorMidlleware` to convert an error that occurred in the controller to a response that conforms to Realworld specifications.
    /// * Set `ServiceType` to relay from Middleware to Controller.
    func initialize() throws{
        
        // Set custom CORS middleware
        let corsConfig = CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
        )
        let cors = CORSMiddleware(configuration: corsConfig)

        // Set custom error handler
        let errorHandle = ErrorMiddleware( errorToResponse )
        
        application.middleware.use( cors )
        application.middleware.use( errorHandle )
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
    func applicationLaunch() throws {
        
        // read hostname and port from environment
        guard
            let hostname = Environment.get("HOSTNAME"),
            let portStr = Environment.get("PORT"), let port = Int(portStr) else {
            throw Error("Your environment not contain HOSTNAME or PORT.")
        }
        
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

        do {
            // inspect the error type
            switch error {
            case let abort as AbortError:
                return try abort.toResponse()
            case let validation as ValidationError:
                return try validation.toResponse()
            case let domainError as Domain.Error:
                return try domainError.toResponse()
            default:
                // not an abort error, and not debuggable or in dev mode
                // just deliver a generic 500 to avoid exposing any sensitive error info
                return Response(
                    status: .internalServerError,
                    headers: .jsonType,
                    body: try Response.Body( GenericErrorModelErrors(body: [error.localizedDescription]) )
                )
            }
        } catch {
            return Response(
                status: .internalServerError,
                headers: .plainTextType,
                body: .init(string: "Oops😣: \(error)")
            )
        }
    }
}


extension Response.Body{
    
    init<T>(_ encodable: T) throws where T: Encodable{
        self.init(data: try JSONEncoder().encode(encodable))
    }
}
