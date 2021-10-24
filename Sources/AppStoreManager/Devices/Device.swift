//
//  Device.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

/// The structure representing a device returned by `AppStoreConnect API`
///
/// https://developer.apple.com/documentation/appstoreconnectapi/device
public struct Device: Decodable {

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
    }
}

extension Device {
    public class Attributes: Decodable {
        public let deviceClass: DeviceClass?
        public let model: String?
        public let name: String?
        public let platform:  BundleIdPlatform?
        public let status: Status?
        public let udid: String?
        public let addedDate: Date?

        public init(
            deviceClass: Device.DeviceClass?,
            model: String?,
            name: String?,
            platform: BundleIdPlatform?,
            status: Device.Status?,
            udid: String?,
            addedDate: Date?) {
            
            self.deviceClass = deviceClass
            self.model = model
            self.name = name
            self.platform = platform
            self.status = status
            self.udid = udid
            self.addedDate = addedDate
        }

    }
}

extension Device {

    public enum DeviceClass: String, Decodable {
        case appleWatch = "APPLE_WATCH"
        case iPad = "IPAD"
        case iPhone = "IPHONE"
        case iPod = "IPOD"
        case appleTV = "APPLE_TV"
        case mac = "MAC"
    }

    public enum Status: String, Codable {
        case enabled = "ENABLED"
        case disabled = "DISABLED"
    }
}
