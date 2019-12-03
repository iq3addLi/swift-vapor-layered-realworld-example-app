//
//  BackendFrameworkRepository.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//


/// A repository that abstracts requests to the backend framework.
protocol FrameworkRepository: Repository {
    
    func initalize()
    
    func routing( collections: [APICollection] )
    
    func applicationLaunch(hostname: String, port: Int) throws
}
