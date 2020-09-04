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
    private let conduit: ConduitRepository = ConduitMySQLRepository.shared
    
    // MARK: Initalizer
    
    /// Default initializer.
    public init() {}

//    deinit{
//        print("呼ばれた😢")
//    }
    
    // MARK: Use cases for application
    
    /// This use case has work of project initialization.
    /// - throws:
    ///    See `ConduitMySQLRepository.ifneededPreparetion()`.
    public func initialize() throws {
        try conduit.ifneededPreparetion()
        try framework.initialize()
    }

    /// This use case has work of routing instruction.
    /// - Parameter collections: Routing instruction array. See `APICollection`. 
    public func routing( collections: [APICollection] ) {
        framework.routing(collections: collections)
    }

    /// This use case has work of application launch.
    /// - throws:
    ///    See `VaporApplicationRepository.applicationLaunch(hostname:port:)`.
    public func launch() throws {
        try framework.applicationLaunch()
    }
}
