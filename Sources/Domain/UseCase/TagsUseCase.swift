//
//  TagsUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

/// Use cases for Tags.
public struct TagsUseCase: UseCase {
    
    // MARK: Properties
    
    /// See `ConduitMySQLRepository`.
    private let conduit: ConduitRepository = ConduitMySQLRepository()

    
    // MARK: Initializer
    
    /// Default initializer.
    public init() {}

    
    // MARK: Use cases for tags
    
    /// This use case has work of get all tags in services.
    /// - returns:
    ///    The `Future` that returns `TagsResponse`.
    public func allTags() -> Future<TagsResponse> {
        conduit.allTags()
            .map { tags in
                TagsResponse(tags: tags )
            }
    }
}
