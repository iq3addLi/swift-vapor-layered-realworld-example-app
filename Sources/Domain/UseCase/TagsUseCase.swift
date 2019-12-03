//
//  TagsUseCase.swift
//  swift-vapor-layered-realworld-example
//
//  Created by iq3AddLi on 2019/09/27.
//

/// Use cases for Tags
public struct TagsUseCase: UseCase {
    
    // MARK: Properties
    
    private let conduit: ConduitRepository = ConduitMySQLRepository()

    // MARK: Functions
    
    /// <#Description#>
    public init() {}
    

    /// <#Description#>
    /// - returns:
    ///    <#Description#> 
    public func allTags() -> Future<TagsResponse> {
        conduit.allTags()
            .map { tags in
                TagsResponse(tags: tags )
            }
    }
}
