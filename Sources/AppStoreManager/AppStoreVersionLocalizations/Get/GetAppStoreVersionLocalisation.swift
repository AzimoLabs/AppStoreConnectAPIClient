//
//  GetAppStoreVersionLocalisation.swift
//  
//
//  Created by Mateusz Kuznik on 25/06/2021.
//

import Foundation

/// https://developer.apple.com/documentation/appstoreconnectapi/list_all_app_store_version_localizations_for_an_app_store_version
public struct GetAppStoreVersionLocalisation {
    /// The version from the GetAppStoreVersionsRequests' response
    public let identifier: String
    public let limit: Int

    public init(identifier: String, limit: Int = 100) {
        self.identifier = identifier
        self.limit = limit
    }
}

extension GetAppStoreVersionLocalisation: Request {

    public struct ResponseObject: Decodable {
        public let attributes: AppStoreVersionLocalization.Attributes
        public let id: String
        public let type: String
    }

    public typealias Response = [ResponseObject]

    public var path: String { "appStoreVersions/\(identifier)/appStoreVersionLocalizations" }

    public var method: HttpMethod {
        return .get
    }

    public var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "limit", value: "\(limit)")]
    }

    public var body: Data? {
        return nil
    }
}
