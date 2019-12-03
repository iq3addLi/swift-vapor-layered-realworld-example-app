//
//  ApplicationUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/11.
//

/// <#Description#>
public class ApplicationUseCase: UseCase {
    private let framework: FrameworkRepository = VaporFrameworkRepository()
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    /// <#Description#>
    public init() {}

    /// <#Description#>
    /// - returns:
    ///    <#Description#>
    public func initialize() throws {

        try conduit.ifneededPreparetion()
        framework.initalize()
    }

    /// <#Description#>
    /// - parameters:
    ///     - collections: <#collections description#>
    /// - returns:
    ///    (dummy)
    public func routing( collections: [APICollection] ) {
        framework.routing(collections: collections)
    }

    /// <#Description#>
    public func launch() throws {
        try framework.applicationLaunch(hostname: "0.0.0.0", port: 8080)
    }
}
