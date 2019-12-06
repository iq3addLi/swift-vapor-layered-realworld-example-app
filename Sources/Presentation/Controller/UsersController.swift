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
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func postUser(_ request: Request) throws -> Future<Response> {
        let useCase = self.useCase
        return try request.content.decode(json: NewUserRequest.self, using: .custom(dates: .iso8601))
            .flatMap { newUserRequest -> EventLoopFuture<UserResponse> in
                try useCase.register(user: newUserRequest.user)
            }
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// POST /users/login
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func login(_ request: Request) throws -> Future<Response> {
        let useCase = self.useCase
        return try request.content.decode(json: LoginUserRequest.self, using: .custom(dates: .iso8601))
            .flatMap { req in
                // Log-in user
                useCase.login(form: req.user)
            }
            .map { response in
                request.response( response, as: .json)
            }
    }

    /// GET /user
    ///
    /// Auth then search user.
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func getUser(_ request: Request) throws -> Future<Response> {
        let user = try request.privateContainer.make(VerifiedUser.self).user
        let response = UserResponse(user: user)
        // Create response
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }

    /// PUT /user
    ///
    /// Auth then expand payload.
    /// - Parameter request: <#request description#>
    /// - throws:
    ///    <#Description#>
    /// - returns:
    ///    <#Description#>
    func updateUser(_ request: Request) throws -> Future<Response> {

        // Get relayed parameter
        let user = (try request.privateContainer.make(VerifiedUserEntity.self))

        // Parse json body
        let useCase = self.useCase
        return try request.content.decode(json: UpdateUserRequest.self, using: .custom(dates: .iso8601))
            .flatMap { req in
                // Verify then update user
                useCase.update(userId: user.id!, token: user.token!, updateUser: req.user )
            }
            .map { response in
                request.response( response, as: .json)
            }
    }

}
