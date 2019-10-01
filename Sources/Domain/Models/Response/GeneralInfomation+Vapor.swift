//
//  GeneralInfomation.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/20.
//

import Vapor

extension GeneralInfomation: Content{}

extension GeneralInfomation: LosslessHTTPBodyRepresentable{
    public func convertToHTTPBody() -> HTTPBody{
        return try! HTTPBody(data: JSONEncoder().encode(self))
    }
}
