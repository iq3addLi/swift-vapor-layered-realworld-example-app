//
//  ApplicationUseCase.swift
//  Domain
//
//  Created by iq3AddLi on 2019/09/11.
//

/// Use cases for starting server applications.
public struct ApplicationUseCase: UseCase {
    
    // MARK: Properties
    
    // See `VaporApplicationRepository`.
    private let framework: RESTApplicationRepository = VaporApplicationRepository()
    
    // See `ConduitMySQLRepository`.
    private let conduit: ConduitRepository = ConduitMySQLRepository()
    
    // MARK: Initalizer
    
    /// Default initializer.
    public init() {}

    // MARK: Use cases for application
    
    /// This use case has work of project initialization.
    /// - throws:
    ///    <#Description#>
    public func initialize() throws {

        try conduit.ifneededPreparetion()
        framework.initalize()
    }

    /// This use case has work of routing instruction.
    /// - Parameter collections: Routing instruction array. See `APICollection`. 
    public func routing( collections: [APICollection] ) {
        framework.routing(collections: collections)
    }

    /// This use case has work of application launch.
    /// - throws:
    ///    <#Description#> 
    public func launch() throws {
        try framework.applicationLaunch(hostname: "0.0.0.0", port: 8080)
    }
}
