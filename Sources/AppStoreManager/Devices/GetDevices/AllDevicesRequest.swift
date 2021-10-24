//
//  AllDevicesRequest.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

///https://developer.apple.com/documentation/appstoreconnectapi/list_devices
public struct AllDevicesRequest {

    public let filters: Set<Filter>
    public let limit: Int

    public init(
        filters: Set<Filter> = Set(),
        limit: Int = 100) {

        self.filters = filters
        self.limit = limit
    }

    public enum Filter: Hashable {
        case identifer(String)
        case name(String)
        case platform(BundleIdPlatform)
        case status(Device.Status)
        case udid(String)
    }

    private func getQueryItems() -> [URLQueryItem] {
        let filtersParameters = filters.map(QueryItemDataFactory().createQueryItem)
        let limitParameter = URLQueryItem(name: "limit", value: "\(limit)")

        return filtersParameters + [limitParameter]
    }
}

extension AllDevicesRequest.Filter: QueryItemData {
    var name: String {
        let item: String
        switch self {
        case .identifer:
            item = "id"
        case .name:
            item = "name"
        case .platform:
            item = "platform"
        case .status:
            item = "status"
        case .udid:
            item = "udid"
        }
        return "filter[\(item)]"
    }

    var value: String {
        switch self {
        case let .identifer(value),
             let .name(value),
             let .udid(value):

            return value
        case let .platform(value):
            return value.rawValue
        case let .status(value):
            return value.rawValue
        }
    }
}

extension AllDevicesRequest: Request {
    public typealias Response = [Device]

    public var path: String {
        return "devices"
    }

    public var queryItems: [URLQueryItem] {
        return getQueryItems()
    }

    public var method: HttpMethod {
        return .get
    }
}
