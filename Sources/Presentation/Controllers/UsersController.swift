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
        return try request.content.decode(json: NewUserRequest.self, using: JSONDecoder()).map { newUserRequest in
            // Register user
            guard let response = try self.useCase.register(user: newUserRequest.user) else{
                // Abort
                throw Abort( .internalServerError )
            }
            
            return request.response( response , as: .json)
        }
    }
    
    // POST /users/login
    func login(_ request: Request) throws -> Future<Response> {
        
        return try request.content.decode(json: LoginUserRequest.self, using: JSONDecoder()).map { loginUserRequest in
            // Log-in user
            guard let response = try self.useCase.login(form: loginUserRequest.user) else{
                // Abort
                throw Abort( .internalServerError )
            }
            
            return request.response( response, as: .json)
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
        let payload = (try request.privateContainer.make(SessionPayload.self))
        
        // Parse json body
        return try request.content.decode(json: UpdateUserRequest.self, using: JSONDecoder()).map { updateUserRequest in
            
            // Verify then update user
            guard let response = try self.useCase.update(userId: payload.id, updateUser: updateUserRequest.user, token: payload.token )  else{
                // Abort
                throw Abort( .internalServerError )
            }
            return request.response( response , as: .json)
        }
    }
    
}
