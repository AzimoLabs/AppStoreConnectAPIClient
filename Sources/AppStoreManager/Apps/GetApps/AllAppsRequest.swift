//
//  AllAppsRequest.swift
//  
//
//  Created by Mateusz Kuznik on 16/06/2021.
//

import Foundation

///https://developer.apple.com/documentation/appstoreconnectapi/list_apps
public struct AllAppsRequest {
    public let limit: Int

    public init(limit: Int) {
        self.limit = limit
    }
}

extension AllAppsRequest: Request {
    public typealias Response = [App]

    public var path: String {
        return "apps"
    }

    public var queryItems: [URLQueryItem] {
        return [URLQueryItem(name: "limit", value: "\(limit)")]
    }

    public var method: HttpMethod {
        return .get
    }
}
