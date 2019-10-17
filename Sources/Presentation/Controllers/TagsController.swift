//
//  TagsController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

public struct TagsController {
    
    let useCase = TagsUseCase()
    
    // GET /tags
    func getTags(_ request: Request) throws -> Future<Response> {
        return request.response( try useCase.allTags(), as: .json).encode(status: .ok, for: request)
    }
}
