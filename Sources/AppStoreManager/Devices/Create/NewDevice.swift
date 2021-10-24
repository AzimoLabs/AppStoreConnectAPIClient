//
//  NewDevice.swift
//  
//
//  Created by Mateusz Kuznik on 17/11/2019.
//

import Foundation

public struct NewDevice: Encodable {

    public let name: String
    public let platform: BundleIdPlatform
    public let identifier: String


    public init(
        name: String,
        platform: BundleIdPlatform,
        identifier: String) {

        self.name = name
        self.platform = platform
        self.identifier = identifier
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case platform
        case identifier = "udid"
    }
}

public struct NewDeviceAttributes<Attributes: Encodable>: Encodable {

    internal let type = "devices"
    public let attributes: Attributes

    public init(attributes: Attributes) {
        self.attributes = attributes
    }
}
