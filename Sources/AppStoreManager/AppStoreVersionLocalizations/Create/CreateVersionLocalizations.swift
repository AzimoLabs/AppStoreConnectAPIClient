//
//  CreateVersionLocalizations.swift
//  
//
//  Created by Mateusz Kuznik on 24/06/2021.
//

import Foundation


/**
 https://developer.apple.com/documentation/appstoreconnectapi/create_an_app_store_version_localization

Expected json (not all possible attributes are listed)
{
    "data": { //use BodyParameters struct
        attributes: {
            "locale": String,
            "whatsNew": String
        },
        "relationships": {
            "appStoreVersion": {
                "data": {
                    "id": String, //8.0.0
                    "type": "appStoreVersions"
                }
            }
        },
        "type": "appStoreVersionLocalizations"
    }
}

 */
public struct CreateVersionLocalizations: Encodable {

    let relationships: Relationships
    let attributes: AppStoreVersionLocalization.Attributes
    let type = "appStoreVersionLocalizations"

    public init(
        version: String,
        attributes: AppStoreVersionLocalization.Attributes) {

        self.relationships = Relationships(
            appStoreVersion: .init(data: .init(id: version)))
        self.attributes = attributes
    }

    private enum CodingKeys: String, CodingKey {
        case attributes
        case relationships
        case type
    }
}

extension CreateVersionLocalizations {

    struct Relationships: Encodable {
        let appStoreVersion: BodyParameters<AppStoreVersion>

        struct AppStoreVersion: Encodable {
            let type = "appStoreVersions"
            let id: String
        }
    }
}
