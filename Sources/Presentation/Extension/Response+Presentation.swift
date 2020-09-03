//
//  Response+Presentation.swift
//  Presentation
//
//  Created by Ikumi Arakane on 2020/09/03.
//

import Vapor

extension Response{
    convenience init<T>(_ encodable: T) throws where T: Encodable{
        self.init( body: Response.Body(data: try JSONEncoder().encode(encodable) ))
    }
}
