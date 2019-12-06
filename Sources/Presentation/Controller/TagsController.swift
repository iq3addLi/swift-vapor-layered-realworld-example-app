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

    // MARK: Properties
    
    /// The use case for tags.
    ///
    /// See `TagsUseCase`.
    private let useCase = TagsUseCase()

    
    // MARK: Controller for tags
    
    // GET /tags
    /// - Parameter request: See `Vapor.Request`.
    /// - throws:
    ///    Normally, no error is thrown in this function.
    /// - returns:
    ///    The `Future` that returns `Response`. 
    func getTags(_ request: Request) throws -> Future<Response> {
        useCase.allTags()
            .map { response in
                request.response( response, as: .json)
            }
    }
}
