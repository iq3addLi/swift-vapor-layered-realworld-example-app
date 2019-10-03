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
        return try request.content.decode(json: NewUserRequest.self, using: JSONDecoder()).map { (newUserRequest) in
            
            let response = try self.useCase.register(user: newUserRequest.user)
            
            return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
        }
    }
    
    // POST /users/login
    func login(_ request: Request) throws -> Future<Response> {
        
        return try request.content.decode(json: LoginUserRequest.self, using: JSONDecoder()).map { (loginUserRequest) in
            
            let response = try self.useCase.login(form: loginUserRequest.user)
            
            return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
        }
    }
    

    // GET /user
    func getUser(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // PUT /user
    func updateUser(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
}
