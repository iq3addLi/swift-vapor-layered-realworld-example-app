//
//  BackendFrameworkRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//


/// A repository that abstracts requests to the backend framework.
///
/// ### Extras
/// It may be that you don't feel good about using Vapor but getting ready when Vapor becomes unavailable.
/// However, I think the server-side application engineer can sympathize with you if you want to be able to migrate from a specific framework at any time.
/// My attempt has not been fully accomplished because `APICollection` depend on Vapor.
/// On the RealWorld scale, the Domain layer is thin. For this reason, replacing the framework will almost rewrite the code in the project. Then, you may not feel the benefits of this configuration. However, I think that the benefits will be felt if the project scale becomes a little larger.
/// I think that Vapor is great because ORMapper, Validation, etc. are considered modulability.
protocol RESTApplicationRepository: Repository {
    
    // MARK: Functions
    
    /// RESTApplicationRepository must to implement initialization process.
    ///
    /// If there is no need for initialization, implementation it empty.
    func initalize()
    
    /// RESTApplicationRepository must to accept routing instructions.
    /// - Parameter collections: Routing instruction array. See `APICollection`. 
    func routing( collections: [APICollection] )
    
    /// RESTApplicationRepository must implement server application launch.
    /// - Parameters:
    ///   - hostname: Host name where the server starts. ex. `"127.0.0.1"`.
    ///   - port: Server port number. ex. `80`.
    /// - throws:
    ///    <#Description#> 
    func applicationLaunch(hostname: String, port: Int) throws
}
