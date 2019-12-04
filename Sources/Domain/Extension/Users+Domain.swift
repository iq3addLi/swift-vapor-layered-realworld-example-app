//
//  Users+Domain.swift
//  Domain
//
//  Created by iq3AddLi on 2019/12/03.
//

import Infrastructure

/// Extensions required by Domain
extension Users {
    public func profile( following: Bool) -> Profile {
        return Profile(username: username, bio: bio, image: image, following: following)
    }
}
