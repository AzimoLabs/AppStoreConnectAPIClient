//
//  Request.swift
//  
//
//  Created by Mateusz Kuznik on 17/11/2019.
//

import Foundation

public protocol Request {
    associatedtype Response: Decodable
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HttpMethod { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
}

extension Request {

    public var queryItems: [URLQueryItem] {
        return []
    }

    public var body: Data? {
        return nil
    }

    public var timeoutInterval: TimeInterval {
        return 10
    }

}

internal protocol QueryItemData {
    var name: String { get }
    var value: String { get }
}

internal struct QueryItemDataFactory {
    internal func createQueryItem(using data: QueryItemData) -> URLQueryItem {
        return URLQueryItem(name: data.name, value: data.value)
    }
}
