//
//  TagsController.swift
//  Presentation
//
//  Created by iq3AddLi on 2019/09/11.
//

import Domain
import Vapor

/// Controller For Tag processing
struct TagsController {

    private let useCase = TagsUseCase()

    // GET /tags
    func getTags(_ request: Request) throws -> Future<Response> {
        useCase.allTags()
            .map { response in
                request.response( response, as: .json)
            }
    }
}
