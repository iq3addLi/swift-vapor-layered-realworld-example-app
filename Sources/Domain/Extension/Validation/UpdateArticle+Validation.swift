//
//  UpdateArticle+Validation.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/30.
//

import Validation

extension UpdateArticle: Validatable, Reflectable {

    public static func validations() throws -> Validations<UpdateArticle> {
        var validations = Validations(UpdateArticle.self)
        try validations.add(\.body, .count(1...1000) || .nil )
        return validations
    }
}

