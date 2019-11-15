//
//  UpdateUser+Validation.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/30.
//

import Validation

extension UpdateUser: Validatable, Reflectable {

    public static func validations() throws -> Validations<UpdateUser> {
        var validations = Validations(UpdateUser.self)
        try validations.add(\.image, .url || .nil )
        return validations
    }
}

