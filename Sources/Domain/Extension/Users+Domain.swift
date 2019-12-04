//
//  Users+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//

import Infrastructure

/// Extensions required by Domain
extension Users {
    
    // Mark: Export to Domain model
    /// Export to `Profile`
    /// - Parameter following: Follow infomation. Missing properties in `Users`.
    public func profile( following: Bool) -> Profile {
        return Profile(username: username, bio: bio, image: image, following: following)
    }
}
