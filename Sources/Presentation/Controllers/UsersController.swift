//
//  AuthController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public struct UsersController {
    
    let useCase = UsersUseCase()
    
    // POST /users
    func postUser(_ request: Request) throws -> Future<Response> {
        try request.content.decode(json: NewUserRequest.self, using: JSONDecoder())
            .flatMap { newUserRequest -> EventLoopFuture<UserResponse> in
                try self.useCase.register(user: newUserRequest.user)
            }
            .flatMap { response -> Future<Response> in
                request.response( response , as: .json).encode(status: .ok, for: request )
            }
    }
    
    // POST /users/login
    func login(_ request: Request) throws -> Future<Response> {
        
        try request.content.decode(json: LoginUserRequest.self, using: JSONDecoder()).map { loginUserRequest in
            // Log-in user
            let response = try self.useCase.login(form: loginUserRequest.user)
            
            return request.response( response, as: .json) // .encode(status: .ok, for: request )
        }
    }
    

    // GET /user Auth then search user
    func getUser(_ request: Request) throws -> Future<Response> {
        
        // Had I my infomation?
        let user = (try request.privateContainer.make(AuthedUser.self)).toResponse()
        let response = UserResponse(user: user)
        
        // Create response
        return request.response( response, as: .json).encode(status: .ok, for: request)
    }
    
    // PUT /user Auth then expand payload
    func updateUser(_ request: Request) throws -> Future<Response> {
        
        // Get relayed parameter
        let user = (try request.privateContainer.make(VerifiedUserEntity.self))
        
        // Parse json body
        return try request.content.decode(json: UpdateUserRequest.self, using: JSONDecoder()).map { updateUserRequest in
            
            // Verify then update user
            let response = try self.useCase.update(userId: user.id!, updateUser: updateUserRequest.user, token: user.token! )
            return request.response( response , as: .json) // .encode(status: .ok, for: request )
        }
    }
    
}
