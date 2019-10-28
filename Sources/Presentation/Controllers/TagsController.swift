//
//  TagsController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Vapor
import Domain

/// dummy comment
struct TagsController {
    
    let useCase = TagsUseCase()
    
    // GET /tags
    func getTags(_ request: Request) throws -> Future<Response> {
        useCase.allTags()
            .map{ response in
                request.response( response, as: .json)
            }
    }
}
