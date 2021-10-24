//
//  UpdateDeviceRequest.swift
//  
//
//  Created by Mateusz Kuznik on 06/12/2019.
//

import Foundation

public struct UpdateDeviceRequest {
    public let httpBody: Data
    public let identifier: String

    public init(for device: UpdateDevice, withIdentifier identifier: String) throws {
        let parameters = UpdateDeviceAttributes(identifier: identifier, attributes: device)
        let body = BodyParameters(data: parameters)
        httpBody = try JSONEncoder().encode(body)
        self.identifier = identifier
    }
}

extension UpdateDeviceRequest: Request {
    public typealias Response = Device

    public var path: String {
        return "devices/\(identifier)"
    }
    public var method: HttpMethod {
        return .patch
    }
    public var body: Data? {
        return httpBody
    }
}
