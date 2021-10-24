//
//  AppStoreVersionLocalizationUpdateRequest.swift
//  
//
//  Created by Mateusz Kuznik on 25/06/2021.
//

import Foundation

public struct AppStoreVersionLocalizationUpdateRequest {
    public let createData: Data
    public let id: String

    public init(
        withIdentifier id: String,
        for new: AppStoreVersionLocalizationUpdate) throws {

        let body = BodyParameters(data: new)
        createData = try JSONEncoder().encode(body)
        self.id = id
    }
}

///https://developer.apple.com/documentation/appstoreconnectapi/modify_an_app_store_version_localization
extension AppStoreVersionLocalizationUpdateRequest: Request {

    public struct ResponseObject: Decodable {
        public let attributes: AppStoreVersionLocalization.Attributes
        public let id: String
        public let type: String
    }

    public typealias Response = ResponseObject

    public var path: String { "appStoreVersionLocalizations/\(id)" }

    public var method: HttpMethod {
        return .patch
    }
    public var body: Data? {
        return createData
    }
}
