//
//  CreateVersionLocalizationsRequest.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation

public struct CreateVersionLocalizationsRequest {
    public let createData: Data

    public init(for new: CreateVersionLocalizations) throws {
        let body = BodyParameters(data: new)
        createData = try JSONEncoder().encode(body)
    }
}

extension CreateVersionLocalizationsRequest: Request {

    public struct ResponseObject: Decodable {
        public let attributes: AppStoreVersionLocalization.Attributes
        public let id: String
        public let type: String
    }

    public typealias Response = ResponseObject

    public var path: String { "appStoreVersionLocalizations" }

    public var method: HttpMethod {
        return .post
    }
    public var body: Data? {
        return createData
    }
}
