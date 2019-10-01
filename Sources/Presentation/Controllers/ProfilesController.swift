//
//  ProfilesController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public struct ProfilesController {
    
    let useCase = ProfilesUseCase()
    
    // GET /profiles/{{USERNAME}}
    func getProfile(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // POST /profiles/{{USERNAME}}/follow
    func follow(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
    
    // DELETE /profiles/{{USERNAME}}/follow
    func unfollow(_ request: Request) throws -> Future<Response> {
        return request.response( GeneralInfomation("This API is not implemented yet.") , as: .json)
            .encode(status: .ok, for: request)
    }
}
