//
//  GeneralInfomation.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/20.
//

public struct GeneralInfomation{
    public let infomation: String
    
    public init(_ infomation: String){
        self.infomation = infomation
    }
}

extension GeneralInfomation: Codable{}
