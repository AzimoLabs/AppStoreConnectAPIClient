//
//  Parameters.swift
//  
//
//  Created by Mateusz Kuznik on 29/11/2019.
//

import Foundation

/// Possible actions to perform
enum ActionCommand: String, CaseIterable, HelperDescriptionProvider {
    case registerDevice
    case updateDevice

    func helperDescription() -> String {
        return self.rawValue
    }
}

enum AuthorizationParameter: String, CaseIterable, HelperDescriptionProvider {
    case keyIdentifier = "--keyId"
    case issuerIdentifier = "--issuerId"
    case privateKey = "--privateKey"

    func helperDescription() -> String {
        switch self {
        case .keyIdentifier:
            return "\(self.rawValue) {key}"
        case .issuerIdentifier:
            return "\(self.rawValue) {issuer}"
        case .privateKey:
            return "\(self.rawValue) {private}"
        }
    }
}

enum RegisterDeviceParameter: String, CaseIterable, HelperDescriptionProvider {
    static let commandKey: String? = ActionCommand.registerDevice.rawValue

    case name = "--deviceName"
    case deviceIdentifier = "--deviceId"
    case platform = "--platform"

    func helperDescription() -> String {
        switch self {
        case .name:
            return "\(self.rawValue) {name for a device}"
        case .deviceIdentifier:
            return "\(self.rawValue) {a device deviceIdentifier - UDID}"
        case .platform:
            return "\(self.rawValue) [ios, macOS]"
        }
    }
}

enum UpdateDeviceParameter: String, CaseIterable, HelperDescriptionProvider {
    static let commandKey: String? = ActionCommand.updateDevice.rawValue

    case name = "--deviceName"
    case deviceIdentifier = "--deviceId"

    func helperDescription() -> String {
        switch self {
        case .name:
            return "\(self.rawValue) {name for a device}"
        case .deviceIdentifier:
            return "\(self.rawValue) {a device deviceIdentifier - UDID}"
        }
    }
}
