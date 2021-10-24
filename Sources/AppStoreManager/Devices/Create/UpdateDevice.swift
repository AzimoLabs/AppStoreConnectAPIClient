//
//  File.swift
//  
//
//  Created by Mateusz Kuznik on 06/12/2019.
//

import Foundation

public struct UpdateDevice: Encodable {
    
    public let name: String?
    public let status: Device.Status?

    public init(
        name: String? = nil,
        status: Device.Status? = nil) {

        self.name = name
        self.status = status
    }
}

public struct UpdateDeviceAttributes<Attributes: Encodable>: Encodable {

    internal let type = "devices"
    public let identifier: String
    public let attributes: Attributes

    public init(
        identifier: String,
        attributes: Attributes) {

        self.identifier = identifier
        self.attributes = attributes
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case attributes
        case type
    }
}
