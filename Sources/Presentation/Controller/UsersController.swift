//
//  AuthController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Domain
import Vapor

/// Controller For User processing
struct UsersController {

    // MARK: Properties
    
    /// The use case for users.
    ///
    /// See `UsersUseCase`.
    private let useCase = UsersUseCase()

    // MARK: Controller for users
    
    /// POST /users
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    Normally, no error is thrown in this function.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func postUser(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by body
        let req = try request.content.decode(NewUserRequest.self, using: JSONDecoder.custom(dates: .iso8601))
        
        return try useCase.register(user: req.user).flatMapThrowing { response in
            try Response( response )
        }
    }

    /// POST /users/login
    /// - Parameter request: See `Vapor.Request`. 
    /// - throws:
    ///    Normally, no error is thrown in this function.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func login(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by body
        let req = try request.content.decode(LoginUserRequest.self, using: JSONDecoder.custom(dates: .iso8601))
        
        return useCase.login(form: req.user).flatMapThrowing { response in
            try Response( response )
        }
    }

    /// GET /user
    ///
    /// Auth then search user.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    Normally, no error is thrown in this function.
    /// - returns:
    ///    The `Future` that returns `Response`.
    func getUser(_ request: Request) throws -> Future<Response> {

        // Get relayed parameter
        guard let user = request.storage[VerifiedUser.Key.self]?.user else {
            fatalError("Middleware not passed authenticated user.") // Require
        }
        
        let response = UserResponse(user: user)
        
        // Create response
        return request.eventLoop.makeSucceededFuture( try Response( response ) )
    }

    /// PUT /user
    ///
    /// Auth then expand payload.
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    Normally, no error is thrown in this function.
    /// - returns:
    ///    The `Future` that returns `Response`. 
    func updateUser(_ request: Request) throws -> Future<Response> {
        
        // Get parameter by body
        let req = try request.content.decode(UpdateUserRequest.self, using: JSONDecoder.custom(dates: .iso8601))
        
        // Get relayed parameter
        guard let user = request.storage[VerifiedUserEntity.Key.self] else {
            fatalError("Middleware not passed authenticated user.") // Require
        }

        return useCase.update(userId: user.id!, token: user.token!, updateUser: req.user )
            .flatMapThrowing { response in
                try Response( response )
            }
    }

}
