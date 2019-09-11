//
//  AuthController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

final class AuthController {
    
    // POST /users
    func postUser(_ request: Request) throws -> String {
        return "postUser"
    }
    
    // POST /users/login
    func login(_ request: Request) throws -> String {
        return "login"
    }
    
    // GET /user
    func getUser(_ request: Request) throws -> String {
        return "getUser"
    }
    
    // PUT /user
    func updateUser(_ request: Request) throws -> String {
        return "getUser"
    }
    
}
