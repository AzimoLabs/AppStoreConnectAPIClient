//
//  CreateVersionRequest.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation

public struct CreateVersionRequest {
    public let createData: Data

    public init(for new: CreateVersion) throws {
        let body = BodyParameters(data: new)
        createData = try JSONEncoder().encode(body)
    }
}

//https://developer.apple.com/documentation/appstoreconnectapi/create_an_app_store_version
extension CreateVersionRequest: Request {

    public struct ResponseObject: Decodable {
        public let attributes: AppStoreVersion
        public let id: String
        public let type: String
    }

    public typealias Response = ResponseObject

    public var path: String { "appStoreVersions" }

    public var method: HttpMethod {
        return .post
    }
    public var body: Data? {
        return createData
    }
}
