//
//  GetDeviceRequest.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

public struct GetDeviceRequest {
    public let identifier: String

    public init(identifier: String) {
        self.identifier = identifier
    }
}

extension GetDeviceRequest: Request {
    public typealias RequestBody = Never
    public typealias Response = Device

    public var path: String {
        return "devices/\(identifier)"
    }
    public var method: HttpMethod {
        return .get
    }
}
