//
//  Users+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//

import Infrastructure

// MARK: Export to Domain model

/// Extensions required by Domain.
extension Users {
    
    /// Export to `Profile`.
    /// - Parameter following: Follow infomation. Missing properties in `Users`.
    /// - returns:
    ///    <#Description#>   
    public func profile( following: Bool) -> Profile {
        return Profile(username: username, bio: bio, image: image, following: following)
    }
}
