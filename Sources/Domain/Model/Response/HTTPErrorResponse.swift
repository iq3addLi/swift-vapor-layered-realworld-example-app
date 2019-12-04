//
//  HTTPErrorResponse.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/02.
//

/// Response for expressing HTTPResponse in JSON body
///
/// Often used when returning 404 Not found. Prepared to match the response of production API. I remember that it was not specified as a RealWorld specification.
public struct HTTPErrorResponse: Codable {
    
    // MARK: Properties
    let status: String
    let error: String
    
    // MARK: Initializer
    public init(_ status: String, error: String){
        self.status = status
        self.error = error
    }
}
