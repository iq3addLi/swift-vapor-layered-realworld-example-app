//
//  ApplicationUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/11.
//

/// Use cases for starting server applications
public struct ApplicationUseCase: UseCase {
    
    // MARK: Properties
    
    private let framework: RESTApplicationRepository = VaporApplicationRepository()
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    // MARK: Functions
    
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
