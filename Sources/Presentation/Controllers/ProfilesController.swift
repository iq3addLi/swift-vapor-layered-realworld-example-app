//
//  ProfilesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

final class ProfilesController {
    
    // GET /profiles/{{USERNAME}}
    func getProfile(_ request: Request) throws -> String {
        return "getUser"
    }
    
    // POST /profiles/{{USERNAME}}/follow
    func follow(_ request: Request) throws -> String {
        return "follow"
    }
    
    // DELETE /profiles/{{USERNAME}}/follow
    func unfollow(_ request: Request) throws -> String {
        return "unfollow"
    }
}
