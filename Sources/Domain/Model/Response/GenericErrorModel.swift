//
// GenericErrorModel.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

/// see https://github.com/gothinkster/realworld/blob/master/api/swagger.json
public struct GenericErrorModel: Codable {

    public var errors: GenericErrorModelErrors

    public init(errors: GenericErrorModelErrors) {
        self.errors = errors
    }

}
