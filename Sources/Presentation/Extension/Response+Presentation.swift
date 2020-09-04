//
//  Response+Presentation.swift
//  Presentation
//
//  Created by Ikumi Arakane on 2020/09/03.
//

import Domain
import Vapor

extension Response{
    convenience init<T>(_ encodable: T) throws where T: Encodable{
        self.init(
            headers: .jsonType,
            body: Response.Body(data:
                try JSONEncoder.custom(dates: .formatted(.iso8601withFractionalSeconds)).encode(encodable)
            )
        )
    }
}
