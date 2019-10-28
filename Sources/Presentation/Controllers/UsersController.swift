//
//  AuthController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

struct UsersController {
    
    let useCase = UsersUseCase()
    
    // POST /users
    func postUser(_ request: Request) throws -> Future<Response> {
        let useCase = self.useCase
        return try request.content.decode(json: NewUserRequest.self, using: JSONDecoder())
            .flatMap { newUserRequest -> EventLoopFuture<UserResponse> in
                useCase.register(user: newUserRequest.user)
            }
            .map { response in
                request.response( response , as: .json)
            }
    }
    
    // POST /users/login
    func login(_ request: Request) throws -> Future<Response> {
        let useCase = self.useCase
        return try request.content.decode(json: LoginUserRequest.self, using: JSONDecoder())
            .flatMap { req in
                // Log-in user
                useCase.login(form: req.user)
            }
            .map{ response in
                request.response( response, as: .json)
            }
    }
    

    // GET /user Auth then search user
    func getUser(_ request: Request) throws -> Future<Response> {
        let user = try request.privateContainer.make(AuthedUser.self)
        let response = UserResponse(user: user.toResponse())
        // Create response
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // PUT /user Auth then expand payload
    func updateUser(_ request: Request) throws -> Future<Response> {
        
        // Get relayed parameter
        let user = (try request.privateContainer.make(VerifiedUserEntity.self))
        
        // Parse json body
        let useCase = self.useCase
        return try request.content.decode(json: UpdateUserRequest.self, using: JSONDecoder())
            .flatMap { req in
                // Verify then update user
                useCase.update(userId: user.id!, token: user.token!, updateUser: req.user )
            }
            .map{ response in
                request.response( response, as: .json)
            }
    }
    
}
