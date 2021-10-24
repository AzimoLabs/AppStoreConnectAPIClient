//
//  GetAppStoreVersionsRequests.swift
//  
//
//  Created by Mateusz Kuznik on 25/06/2021.
//

import Foundation

public struct GetAppStoreVersionsRequests {
    public let identifier: String
    public let limit: Int
    public let platform: BundleIdPlatform

    public init(
        identifier: String,
        platform: BundleIdPlatform = .iOS,
        limit: Int = 1) {

        self.identifier = identifier
        self.platform = platform
        self.limit = limit
    }
}

///https://developer.apple.com/documentation/appstoreconnectapi/list_all_app_store_versions_for_an_app
extension GetAppStoreVersionsRequests: Request {

    public struct ResponseObject: Decodable {
        public let attributes: AppStoreVersion
        public let id: String
        public let type: String
    }

    public typealias Response = [ResponseObject]

    public var path: String { "apps/\(identifier)/appStoreVersions" }

    public var method: HttpMethod {
        return .get
    }

    public var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "filter[platform]", value: "\(platform.rawValue)"),
        ]
    }

    public var body: Data? {
        return nil
    }
}
