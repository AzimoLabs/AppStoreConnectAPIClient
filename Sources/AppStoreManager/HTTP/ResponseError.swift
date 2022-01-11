//
//  ResponseError.swift
//  
//
//  Created by Mateusz Kuznik on 31/12/2021.
//

import Foundation


/// https://developer.apple.com/documentation/appstoreconnectapi/errorresponse/errors
public struct ResponseError: Decodable, Error {

    /// The HTTP status code of the error. This status code usually matches the response's status code; however, if the request produces multiple errors, these two codes may differ.
    public let status: String
    /// A machine-readable code indicating the type of error. The code is a hierarchical value with levels of specificity separated by the '.' character. This value is parseable for programmatic error handling in code.
    public let code: String
    /// The unique ID of a specific instance of an error, request, and response. Use this ID when providing feedback to or debugging issues with Apple.
    public let identifier: String?
    /// A summary of the error. Do not use this field for programmatic error handling.
    public let title: String
    /// A detailed explanation of the error. Do not use this field for programmatic error handling.
    public let detail: String
    /// One of two possible types of values: source.parameter, provided when a query parameter produced the error, or source.JsonPointer, provided when a problem with the entity produced the error.
    ///
    /// Possible types:
    /// 1. (ErrorResponse.Errors.JsonPointer)[https://developer.apple.com/documentation/appstoreconnectapi/errorresponse/errors/jsonpointer],
    /// 1. (ErrorResponse.Errors.Parameter)[https://developer.apple.com/documentation/appstoreconnectapi/errorresponse/errors/parameter]
    public let source: [String: String]?

    internal init(
        status: String,
        code: String,
        identifier: String?,
        title: String,
        detail: String,
        source: [String: String]?) {

        self.status = status
        self.code = code
        self.identifier = identifier
        self.title = title
        self.detail = detail
        self.source = source
    }
}
