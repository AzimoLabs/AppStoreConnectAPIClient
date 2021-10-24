//
//  NewDeviceRequest.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

public struct NewDeviceRequest {
    public let newDeviceData: Data

    public init(for newDevice: NewDevice) throws {
        let parameters = NewDeviceAttributes(attributes: newDevice)
        let body = BodyParameters(data: parameters)
        newDeviceData = try JSONEncoder().encode(body)
    }
}

extension NewDeviceRequest: Request {
    public typealias Response = Device

    public var path: String {
        return "devices"
    }
    public var method: HttpMethod {
        return .post
    }
    public var body: Data? {
        return newDeviceData
    }
}
