//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 07/04/2020.
//

import Foundation

public struct AllBuildsRequest {

    public let filters: Set<Filter>
    public let limit: Int

    public init(
        filters: Set<Filter> = Set(),
        limit: Int = 100) {

        self.filters = filters
        self.limit = limit
    }

    private func getQueryItems() -> [URLQueryItem] {
        let filtersParameters = filters.map(QueryItemDataFactory().createQueryItem)
        let limitParameter = URLQueryItem(name: "limit", value: "\(limit)")

        return filtersParameters + [limitParameter]
    }
}

extension AllBuildsRequest {

    public enum Filter: Hashable {
        case version(String)
        case appIdentifier(String)
        case processingState([Build.ProcessingState])
    }
}

extension AllBuildsRequest.Filter: QueryItemData {
    var name: String {
        let item: String
        switch self {
        case .version:
            item = "version"
        case .appIdentifier:
            item = "app"
        case .processingState:
            item = "processingState"
        }
        return "filter[\(item)]"
    }

    var value: String {
        switch self {
        case let .version(value),
             let .appIdentifier(value):
            return value
        case let .processingState(state):
            return state.map(\.rawValue).joined(separator: ",")
        }
    }
}

extension AllBuildsRequest: Request {
    public typealias Response = [Build]

    public var path: String {
        return "builds"
    }

    public var queryItems: [URLQueryItem] {
        return getQueryItems()
    }

    public var method: HttpMethod {
        return .get
    }
}
