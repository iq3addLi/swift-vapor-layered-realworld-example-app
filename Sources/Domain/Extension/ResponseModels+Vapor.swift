//
//  ResponseModels+Vapor.swift
//  Domain
//
//  Created by iq3AddLi on 2019/10/01.
//

import Vapor

extension Article: LosslessHTTPBodyRepresentable {}
extension Comment: LosslessHTTPBodyRepresentable {}
extension GenericErrorModel: LosslessHTTPBodyRepresentable {}
extension GenericErrorModelErrors: LosslessHTTPBodyRepresentable {}
extension MultipleArticlesResponse: LosslessHTTPBodyRepresentable {}
extension MultipleCommentsResponse: LosslessHTTPBodyRepresentable {}
extension Profile: LosslessHTTPBodyRepresentable {}
extension ProfileResponse: LosslessHTTPBodyRepresentable {}
extension SingleArticleResponse: LosslessHTTPBodyRepresentable {}
extension SingleCommentResponse: LosslessHTTPBodyRepresentable {}
extension TagsResponse: LosslessHTTPBodyRepresentable {}
extension User: LosslessHTTPBodyRepresentable {}
extension UserResponse: LosslessHTTPBodyRepresentable {}
extension EmptyResponse: LosslessHTTPBodyRepresentable {}

// MARK: Convert to HTTPBody

/// Extensions required by Domain.
extension LosslessHTTPBodyRepresentable where Self: Codable {
    
    /// Convert to HTTPBody.
    /// - returns:
    ///    See `HTTPBody`
    public func convertToHTTPBody() -> HTTPBody {
        return try! HTTPBody(data: JSONEncoder.custom(dates: .formatted(.iso8601withFractionalSeconds)).encode(self))
    }
}
