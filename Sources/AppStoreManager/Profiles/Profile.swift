//
//  Profile.swift
//  
//
//  Created by Mateusz Kuznik on 20/11/2019.
//

import Foundation

public struct Profile: Decodable {

    public let identifier: String
    public let attributes: [Attributes]?
    public let links: ResourceLinks

    public init(
        identifier: String,
        attributes: [Profile.Attributes]?,
        links: ResourceLinks) {

        self.identifier = identifier
        self.attributes = attributes
        self.links = links
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case attributes
        case links
    }
}

extension Profile {

    public struct Attributes: Decodable {

        public let name: String?
        public let platform: BundleIdPlatform?
        public let profileContent: String?
        public let uuid: UUID?
        public let createdDate: Date?
        public let profileState: State?
        public let profileType: Kind?
        public let expirationDate: Date?

        public init(
            name: String?,
            platform: BundleIdPlatform?,
            profileContent: String?,
            uuid: UUID?,
            createdDate: Date?,
            profileState: Profile.State?,
            profileType: Profile.Kind?,
            expirationDate: Date?) {

            self.name = name
            self.platform = platform
            self.profileContent = profileContent
            self.uuid = uuid
            self.createdDate = createdDate
            self.profileState = profileState
            self.profileType = profileType
            self.expirationDate = expirationDate
        }
    }

    public enum State: String, Decodable {
        case active = "ACTIVE"
        case invalid = "INVALID"
    }

    public enum Kind: String, Decodable {
        case iosAppDevelopment = "IOS_APP_DEVELOPMENT"
        case iosAppStore = "IOS_APP_STORE"
        case iosAppAdHoc = "IOS_APP_ADHOC"
        case iosAppInhouse = "IOS_APP_INHOUSE"
        case macAppDevelopment = "MAC_APP_DEVELOPMENT"
        case macAppStore = "MAC_APP_STORE"
        case macAppDirect = "MAC_APP_DIRECT"
        case tvOSAppDevelopment = "TVOS_APP_DEVELOPMENT"
        case tvOSAppStore = "TVOS_APP_STORE"
        case tvOSAppAdHoc = "TVOS_APP_ADHOC"
        case tvOSAppInhouse = "TVOS_APP_INHOUSE"
    }
}
