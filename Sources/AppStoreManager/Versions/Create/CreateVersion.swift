//
//  CreateVersion.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation

public struct CreateVersion: Encodable {
    public let attributes: Attributes
    public let relationships: Relationships
    let type = "appStoreVersions"

    public init(attributes: Attributes, app: App) {
        self.attributes = attributes
        self.relationships = .init(app: .init(data: app))
    }
}

extension CreateVersion {

    public struct Attributes: Encodable {
        public let platform: BundleIdPlatform
        public let versionString: String

        public init(platform: BundleIdPlatform, versionString: String) {
            self.platform = platform
            self.versionString = versionString
        }

    }

    public struct App: Encodable {
        /// The app id
        public let id: String
        public let type = "apps"

        public init(id: String) {
            self.id = id
        }

    }

    public struct Relationships: Encodable {
        let app: BodyParameters<App>
    }
}
